import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/db/database.dart';
import 'config.dart';
import '../data/files/image_migration.dart';
import '../data/files/image_storage.dart';
import '../data/images/background_remover.dart';
import '../data/intake/garment_intake.dart';
import '../data/notifications/daily_reminder.dart';
import '../data/prefs/app_prefs.dart';
import '../data/remote/auth_service.dart';
import '../data/remote/closet_restore.dart';
import '../data/remote/closet_sync.dart';
import '../data/remote/convex_client.dart';
import '../data/repos/catalog_repository.dart';
import '../data/repos/garment_repository.dart';
import '../data/repos/outfit_repository.dart';
import '../data/repos/laundry_repository.dart';
import '../data/repos/plan_repository.dart';
import '../data/weather/weather_repository.dart';
import '../data/weather/weather_service.dart';
import '../domain/models/catalog.dart';
import '../domain/models/garment.dart';
import '../domain/models/outfit.dart';
import '../domain/outfit/outfit_engine.dart';
import '../domain/outfit/wear_history.dart';
import '../ui/labels.dart';

/// Providers manuales en vez de codegen: `riverpod_generator` exige
/// analyzer 13, que hoy choca con las dependencias de drift y del propio
/// `flutter_test`. La sintaxis manual no tiene esa restricción.

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final imageStorageProvider =
    FutureProvider<ImageStorage>((ref) => ImageStorage.instance());

/// Recomprime al formato actual las imagenes de versiones anteriores y
/// barre la cache. Devuelve los bytes liberados. Lo arranca [IvyroomApp].
final imageMigrationProvider = FutureProvider<int>((ref) async {
  final storage = await ref.watch(imageStorageProvider.future);
  try {
    final freed = await ImageMigration(
      storage: storage,
      garments: ref.watch(garmentRepositoryProvider),
      cacheDirectory: await getTemporaryDirectory(),
    ).run();
    return freed;
  } catch (e, st) {
    debugPrint('[ivy] migracion fallo: $e '
        '$st');
    rethrow;
  }
});

final garmentRepositoryProvider = Provider<GarmentRepository>(
    (ref) => GarmentRepository(ref.watch(databaseProvider)));

final catalogRepositoryProvider = Provider<CatalogRepository>(
    (ref) => CatalogRepository(ref.watch(databaseProvider)));

final outfitRepositoryProvider = Provider<OutfitRepository>((ref) =>
    OutfitRepository(
        ref.watch(databaseProvider), ref.watch(garmentRepositoryProvider)));

final backgroundRemoverProvider = Provider<BackgroundRemover>((ref) {
  final remover = MlKitBackgroundRemover();
  ref.onDispose(remover.dispose);
  return remover;
});

/// El alta de prenda completa. Depende de `ImageStorage`, que es asíncrono,
/// así que este provider también lo es.
final garmentIntakeProvider = FutureProvider<GarmentIntake>((ref) async {
  return GarmentIntake(
    remover: ref.watch(backgroundRemoverProvider),
    storage: await ref.watch(imageStorageProvider.future),
    garments: ref.watch(garmentRepositoryProvider),
  );
});

final outfitEngineProvider =
    Provider<OutfitEngine>((ref) => const RuleOutfitEngine());

// ---- clima -----------------------------------------------------------------

final weatherRepositoryProvider =
    Provider<WeatherRepository>((ref) => WeatherRepository());

/// Estado del clima: preferencia de ubicacion y ultimo dato conocido.
///
/// Carga la cache al arrancar y refresca en segundo plano si esta vieja, de
/// modo que la pantalla de outfits siempre tiene algo que ensenar aunque no
/// haya red.
class WeatherNotifier extends AsyncNotifier<WeatherState> {
  @override
  Future<WeatherState> build() async {
    final repo = ref.watch(weatherRepositoryProvider);
    final saved = await repo.load();

    // Refresco oportunista: no se espera, para no retrasar el arranque.
    if (saved.mode != LocationMode.off && saved.isStale) {
      Future.microtask(refresh);
    }
    return saved;
  }

  WeatherRepository get _repo => ref.read(weatherRepositoryProvider);

  /// Vuelve a consultar el tiempo del sitio configurado.
  Future<void> refresh() async {
    final current = state.value;
    if (current == null || current.mode == LocationMode.off) return;

    state = AsyncData(current.copyWith(loading: true, clearError: true));
    try {
      final place = current.mode == LocationMode.automatic
          ? await _repo.currentPlace()
          : current.place;
      if (place == null) {
        state = AsyncData(current.copyWith(
            loading: false, error: 'No hay ningun sitio configurado.'));
        return;
      }

      final weather = await _repo.forecast(place);
      final next = current.copyWith(
          place: place, weather: weather, loading: false, clearError: true);
      state = AsyncData(next);
      await _repo.save(next);
    } on WeatherException catch (e) {
      // Se conserva el dato viejo: un clima de hace horas es mejor que nada.
      state = AsyncData(current.copyWith(loading: false, error: e.message));
    }
  }

  /// Activa el clima por GPS.
  Future<void> useCurrentLocation() async {
    final current = state.value ?? const WeatherState();
    state = AsyncData(current.copyWith(
        mode: LocationMode.automatic, loading: true, clearError: true));
    await refresh();
    final next = state.value;
    if (next != null) await _repo.save(next);
  }

  /// Fija un sitio buscado a mano.
  Future<void> usePlace(Place place) async {
    final current = state.value ?? const WeatherState();
    state = AsyncData(current.copyWith(
        mode: LocationMode.manual,
        place: place,
        loading: true,
        clearError: true));
    await refresh();
    final next = state.value;
    if (next != null) await _repo.save(next);
  }

  /// Vuelve a la temperatura manual con deslizador.
  Future<void> turnOff() async {
    const next = WeatherState();
    state = const AsyncData(next);
    await _repo.save(next);
  }

  Future<List<Place>> search(String query) => _repo.searchPlaces(query);
}

final weatherProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherState>(WeatherNotifier.new);

/// La temperatura que el motor debe usar hoy, o null si no se sabe.
final todayTempProvider = Provider<double?>((ref) {
  final w = ref.watch(weatherProvider).value;
  if (w == null || w.mode == LocationMode.off) return null;
  return w.weather?.dressingTempC;
});

// ---- catálogos -------------------------------------------------------------

final categoriesProvider = StreamProvider<List<Category>>(
    (ref) => ref.watch(catalogRepositoryProvider).watchCategories());

final occasionsProvider = StreamProvider<List<Occasion>>(
    (ref) => ref.watch(catalogRepositoryProvider).watchOccasions());

final moodsProvider = StreamProvider<List<Mood>>(
    (ref) => ref.watch(catalogRepositoryProvider).watchMoods());

final tagsProvider = StreamProvider<List<Tag>>(
    (ref) => ref.watch(catalogRepositoryProvider).watchTags());

// ---- lavado ----------------------------------------------------------------

final washGroupRepositoryProvider = Provider<WashGroupRepository>(
    (ref) => WashGroupRepository(ref.watch(databaseProvider)));

final laundryRepositoryProvider = Provider<LaundryRepository>((ref) =>
    LaundryRepository(
        ref.watch(databaseProvider), ref.watch(garmentRepositoryProvider)));

final washGroupsProvider = StreamProvider<List<WashGroup>>(
    (ref) => ref.watch(washGroupRepositoryProvider).watchAll());

final laundryDaysProvider = StreamProvider<List<LaundryDay>>(
    (ref) => ref.watch(laundryRepositoryProvider).watchAll());

/// Candidatas a lavar, ordenadas por lo sucio primero.
///
/// Depende del armario completo para recalcularse sola cuando se marca una
/// prenda como usada o se registra una lavada.
final washCandidatesProvider = FutureProvider<List<WashCandidate>>((ref) async {
  ref.watch(fullWardrobeProvider);
  return ref.watch(laundryRepositoryProvider).candidates();
});

/// Cuantas prendas estan sucias ahora mismo. Alimenta la insignia del menu.
final dirtyCountProvider = Provider<int>((ref) {
  final wardrobe = ref.watch(fullWardrobeProvider).value ?? const [];
  return wardrobe.where((g) => g.needsWashing).length;
});



/// Categorías agrupadas por ranura. Es lo que ordena las secciones del
/// armario y lo que ofrece el desplegable del formulario.
final categoriesBySlotProvider = Provider<Map<Slot, List<Category>>>((ref) {
  final cats = ref.watch(categoriesProvider).value ?? const [];
  final out = <Slot, List<Category>>{};
  for (final c in cats) {
    out.putIfAbsent(c.slot, () => []).add(c);
  }
  return out;
});

// ---- armario ---------------------------------------------------------------

/// Filtro activo del armario.
class ClosetFilterNotifier extends Notifier<ClosetFilter> {
  @override
  ClosetFilter build() => const ClosetFilter();

  void set(ClosetFilter value) => state = value;
  void update(ClosetFilter Function(ClosetFilter) f) => state = f(state);
  void clear() => state = const ClosetFilter();
}

final closetFilterProvider =
    NotifierProvider<ClosetFilterNotifier, ClosetFilter>(
        ClosetFilterNotifier.new);

/// Armario filtrado, reactivo.
final closetProvider = StreamProvider<List<Garment>>((ref) {
  final filter = ref.watch(closetFilterProvider);
  return ref.watch(garmentRepositoryProvider).watchFiltered(
        filter,
        queryColors: Labels.colorFamiliesMatching(filter.query ?? ''),
      );
});

/// Armario completo sin filtrar. Alimenta al motor de outfits, que aplica
/// sus propios filtros y no debe verse limitado por lo que el usuario tenga
/// puesto en la pantalla del armario.
final fullWardrobeProvider = StreamProvider<List<Garment>>(
    (ref) => ref.watch(garmentRepositoryProvider).watchAll());

/// Prendas que no se ponen desde hace tiempo. Ver [Garment.isForgotten].
final forgottenProvider = Provider<List<Garment>>((ref) {
  final all = ref.watch(fullWardrobeProvider).value ?? const [];
  final now = DateTime.now();
  return [for (final g in all) if (g.isForgotten(now)) g];
});

/// Una sección del armario: una categoría y las prendas que contiene.
class ClosetSection {
  const ClosetSection(this.category, this.garments);
  final Category category;
  final List<Garment> garments;
}

/// El armario agrupado en secciones por categoría, respetando el filtro.
///
/// Es la vista por defecto de la pantalla principal: una rejilla plana con
/// cien prendas no dice nada, y agrupada por tipo se navega de un vistazo.
final closetSectionsProvider = Provider<List<ClosetSection>>((ref) {
  final garments = ref.watch(closetProvider).value ?? const [];
  final categories = ref.watch(categoriesProvider).value ?? const [];

  final byCategory = <int, List<Garment>>{};
  for (final g in garments) {
    byCategory.putIfAbsent(g.category.id, () => []).add(g);
  }

  // Se recorre el catálogo y no el mapa para que el orden de las secciones
  // sea el del catálogo (agrupado por slot), no el de inserción.
  return [
    for (final c in categories)
      if (byCategory[c.id]?.isNotEmpty ?? false)
        ClosetSection(c, byCategory[c.id]!),
  ];
});

// ---- outfits ---------------------------------------------------------------

class OutfitRequestNotifier extends Notifier<OutfitRequest> {
  @override
  OutfitRequest build() => const OutfitRequest();

  void set(OutfitRequest value) => state = value;

  /// Vuelve a tirar los dados sin cambiar los filtros.
  void reroll() => state = state.copyWith(seed: state.seed + 1);
}

final outfitRequestProvider =
    NotifierProvider<OutfitRequestNotifier, OutfitRequest>(
        OutfitRequestNotifier.new);

/// La peticion que llega de verdad al motor.
///
/// Es la del usuario, pero con la temperatura del clima sobrepuesta cuando
/// esta activo. Se resuelve aqui y no en la pantalla para que el creador
/// manual de outfits y el generador automatico usen exactamente la misma
/// temperatura sin tener que acordarse cada uno por su cuenta.
final effectiveOutfitRequestProvider = Provider<OutfitRequest>((ref) {
  final req = ref.watch(outfitRequestProvider);
  final auto = ref.watch(todayTempProvider);
  return auto == null ? req : req.copyWith(tempC: auto);
});

/// Sugerencias para la petición actual. Se recalculan solas cuando cambia el
/// armario, la petición o el clima.
final outfitSuggestionsProvider = Provider<List<OutfitSuggestion>>((ref) {
  final wardrobe = ref.watch(fullWardrobeProvider).value;
  if (wardrobe == null) return const [];
  final req = ref.watch(effectiveOutfitRequestProvider);
  final history = ref.watch(wearHistoryProvider).value ?? WearHistory.empty;
  return ref
      .watch(outfitEngineProvider)
      .generate(wardrobe, req, history: history);
});

/// Sugerencias para un dia concreto.
///
/// Se pide con `forDay` para que el motor juzgue el dia de la semana que
/// toca: planificando el martes que viene, lo que importa es que no repita
/// lo del martes pasado.
final suggestionsForDayProvider =
    Provider.family<List<OutfitSuggestion>, DateTime>((ref, day) {
  final wardrobe = ref.watch(fullWardrobeProvider).value;
  if (wardrobe == null) return const [];
  final req = ref.watch(effectiveOutfitRequestProvider).copyWith(forDay: day);
  final history = ref.watch(wearHistoryProvider).value ?? WearHistory.empty;
  return ref
      .watch(outfitEngineProvider)
      .generate(wardrobe, req, history: history);
});

final savedOutfitsProvider = StreamProvider<List<SavedOutfit>>(
    (ref) => ref.watch(outfitRepositoryProvider).watchAll());

// ---- calendario ------------------------------------------------------------

final planRepositoryProvider = Provider<PlanRepository>((ref) =>
    PlanRepository(
      ref.watch(databaseProvider),
      ref.watch(garmentRepositoryProvider),
      ref.watch(outfitRepositoryProvider),
    ));

/// Mes que se esta mirando, por su dia 1.
class CalendarMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void shift(int months) =>
      state = DateTime(state.year, state.month + months, 1);

  void goTo(DateTime date) => state = DateTime(date.year, date.month, 1);
}

final calendarMonthProvider =
    NotifierProvider<CalendarMonthNotifier, DateTime>(
        CalendarMonthNotifier.new);

/// Dia seleccionado en el calendario.
class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => PlanRepository.dayKey(DateTime.now());

  void select(DateTime day) {
    final normalized = PlanRepository.dayKey(day);
    state = normalized;
    // Elegir un dia de otro mes arrastra la rejilla: si no, el usuario
    // seleccionaria algo que deja de ver.
    ref.read(calendarMonthProvider.notifier).goTo(normalized);
  }
}

final selectedDayProvider =
    NotifierProvider<SelectedDayNotifier, DateTime>(SelectedDayNotifier.new);

/// Planes del mes visible, agrupados por dia.
final monthPlansProvider =
    StreamProvider<Map<DateTime, List<DayPlan>>>((ref) {
  final month = ref.watch(calendarMonthProvider);
  final last = DateTime(month.year, month.month + 1, 0);
  return ref.watch(planRepositoryProvider).watchRange(month, last).map((all) {
    final out = <DateTime, List<DayPlan>>{};
    for (final p in all) {
      out.putIfAbsent(p.day, () => []).add(p);
    }
    return out;
  });
});

/// Dias con lavada del mes visible.
final monthLaundryProvider = StreamProvider<Set<DateTime>>((ref) {
  final month = ref.watch(calendarMonthProvider);
  final last = DateTime(month.year, month.month + 1, 0);
  return ref.watch(laundryRepositoryProvider).watchDaysInRange(month, last);
});

/// Opciones del dia seleccionado.
final selectedDayPlansProvider = StreamProvider<List<DayPlan>>((ref) {
  final day = ref.watch(selectedDayProvider);
  return ref.watch(planRepositoryProvider).watchRange(day, day);
});

/// Planes de la semana en curso, para la tira de la pantalla de hoy.
final weekStripProvider =
    StreamProvider<Map<DateTime, List<DayPlan>>>((ref) {
  final today = PlanRepository.dayKey(DateTime.now());
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return ref
      .watch(planRepositoryProvider)
      .watchRange(monday, monday.add(const Duration(days: 6)))
      .map((all) {
    final out = <DateTime, List<DayPlan>>{};
    for (final p in all) {
      out.putIfAbsent(p.day, () => []).add(p);
    }
    return out;
  });
});

/// El plan de hoy, si lo hay.
final todayPlansProvider = StreamProvider<List<DayPlan>>((ref) {
  final today = PlanRepository.dayKey(DateTime.now());
  return ref.watch(planRepositoryProvider).watchRange(today, today);
});

/// Lo que ya se ha llevado puesto, para que el motor no repita.
///
/// Se recalcula cuando cambia el armario o los planes: marcar un dia como
/// usado tiene que cambiar las sugerencias del siguiente inmediatamente.
final wearHistoryProvider = FutureProvider<WearHistory>((ref) async {
  ref.watch(fullWardrobeProvider);
  ref.watch(monthPlansProvider);
  return ref.watch(planRepositoryProvider).wearHistory();
});

/// Dia para el que el creador manual esta armando un outfit, si viene del
/// calendario.
class BuilderTargetDayNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void select(DateTime? day) =>
      state = day == null ? null : PlanRepository.dayKey(day);
}

final builderTargetDayProvider =
    NotifierProvider<BuilderTargetDayNotifier, DateTime?>(
        BuilderTargetDayNotifier.new);

/// Prendas elegidas a mano en el creador de outfits, indexadas por ranura.
///
/// Una ranura admite una sola prenda salvo los accesorios, donde tiene
/// sentido combinar varios.
class OutfitBuilderNotifier extends Notifier<List<Garment>> {
  @override
  List<Garment> build() => const [];

  void toggle(Garment g) {
    final current = [...state];
    if (current.remove(g)) {
      state = current;
      return;
    }
    if (g.slot != Slot.accessory) {
      current.removeWhere((x) => x.slot == g.slot);
    }
    // Un vestido y un conjunto arriba/abajo se excluyen mutuamente.
    if (g.slot == Slot.dress) {
      current.removeWhere((x) => x.slot == Slot.top || x.slot == Slot.bottom);
    } else if (g.slot == Slot.top || g.slot == Slot.bottom) {
      current.removeWhere((x) => x.slot == Slot.dress);
    }
    state = [...current, g];
  }

  void clear() => state = const [];
}

final outfitBuilderProvider =
    NotifierProvider<OutfitBuilderNotifier, List<Garment>>(
        OutfitBuilderNotifier.new);

/// Puntuación en vivo del outfit que se está montando a mano, para que el
/// usuario vea si lo que está eligiendo combina mientras lo elige.
final outfitBuilderScoreProvider = Provider<OutfitSuggestion?>((ref) {
  final items = ref.watch(outfitBuilderProvider);
  if (items.length < 2) return null;
  final target = ref.watch(builderTargetDayProvider);
  return ref.watch(outfitEngineProvider).scoreOne(
        items,
        req: ref
            .watch(effectiveOutfitRequestProvider)
            .copyWith(forDay: target),
        history: ref.watch(wearHistoryProvider).value ?? WearHistory.empty,
      );
});

// ---- preferencias y aviso diario -------------------------------------------

final appPrefsStoreProvider = Provider<AppPrefsStore>(
    (ref) => AppPrefsStore(getApplicationDocumentsDirectory));

class AppPrefsNotifier extends AsyncNotifier<AppPrefs> {
  @override
  Future<AppPrefs> build() => ref.read(appPrefsStoreProvider).load();

  Future<void> change(AppPrefs Function(AppPrefs) f) async {
    final next = f(state.value ?? const AppPrefs());
    state = AsyncData(next);
    await ref.read(appPrefsStoreProvider).save(next);
  }
}

final appPrefsProvider =
    AsyncNotifierProvider<AppPrefsNotifier, AppPrefs>(AppPrefsNotifier.new);

final dailyReminderProvider = Provider<DailyReminder>((ref) => DailyReminder());

/// Planes de hoy y los proximos dias, lo que el aviso necesita saber.
final upcomingPlansProvider = StreamProvider<List<DayPlan>>((ref) {
  final today = PlanRepository.dayKey(DateTime.now());
  return ref.watch(planRepositoryProvider).watchRange(
      today, today.add(const Duration(days: DailyReminder.days - 1)));
});

/// Mantiene los avisos al dia con las preferencias y la planificacion.
/// Lo arranca [IvyroomApp]; no devuelve nada que pintar.
final reminderSyncProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.watch(appPrefsProvider.future);
  final plans = ref.watch(upcomingPlansProvider).value ?? const [];

  // Por dia, la opcion puesta si la hay y si no la primera planificada.
  final byDay = <DateTime, List<String>>{};
  for (final p in plans) {
    if (byDay.containsKey(p.day) && !p.wasWorn) continue;
    byDay[p.day] = [for (final g in p.items) g.displayName];
  }

  try {
    await ref.read(dailyReminderProvider).reschedule(
          enabled: prefs.reminderEnabled,
          minutes: prefs.reminderMinutes,
          plannedByDay: byDay,
        );
  } catch (e) {
    // Sin plugin (tests, escritorio) o sin permiso: la app sigue igual.
    debugPrint('[ivy] no se pudo programar el aviso: $e');
  }
});

// ---- cuenta y sincronizacion -----------------------------------------------

final authServiceProvider = Provider<AuthService>(
    (ref) => AuthService(directory: getApplicationDocumentsDirectory));

final convexProvider = Provider<ConvexClient>((ref) {
  final auth = ref.watch(authServiceProvider);
  return ConvexClient(token: auth.token);
});

/// Un armario que otra persona ha compartido conmigo.
class SharedCloset {
  const SharedCloset({
    required this.closetId,
    required this.ownerName,
    required this.ownerEmail,
  });

  final String closetId;
  final String ownerName;
  final String ownerEmail;
}

/// La sesion abierta en Convex.
class Session {
  const Session({
    required this.email,
    required this.closetId,
    this.name,
    this.photoUrl,
    this.lastSyncAt,
    this.shared = const [],
  });

  final String email;
  final String? name;
  final String? photoUrl;
  final String closetId;
  final DateTime? lastSyncAt;
  final List<SharedCloset> shared;
}

class AccountNotifier extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() async {
    // Sin backend configurado la app es solo local: ni se intenta.
    if (!AppConfig.cloudEnabled) return null;
    final auth = ref.read(authServiceProvider);
    try {
      if (!await auth.restore()) return null;
      return await _open();
    } catch (e) {
      // Sin red o sin servicios de Google: la app funciona igual, solo sin
      // cuenta.
      debugPrint('[ivy] no se pudo recuperar la sesion: $e');
      return null;
    }
  }

  Future<Session> _open() async {
    final v = await ref.read(convexProvider).mutation('users:session') as Map;
    final last = v['lastSyncAt'] as num?;
    return Session(
      email: v['email'] as String,
      name: v['name'] as String?,
      photoUrl: v['picture'] as String?,
      closetId: v['closetId'] as String,
      lastSyncAt: last == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(last.toInt()),
      shared: [
        for (final s in (v['shared'] as List).cast<Map>())
          SharedCloset(
            closetId: s['closetId'] as String,
            ownerName: s['ownerName'] as String,
            ownerEmail: s['ownerEmail'] as String,
          ),
      ],
    );
  }

  Future<void> signIn() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signIn();
      return _open();
    });
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    state = const AsyncData(null);
  }

  /// Vuelve a pedir la sesion: armarios compartidos, ultima sincronizacion.
  Future<void> refresh() async {
    if (state.value == null) return;
    // Si falla (sin red) se queda lo que habia: un refresco fallido no puede
    // parecer que se cerro la sesion.
    try {
      state = AsyncData(await _open());
    } catch (e) {
      debugPrint('[ivy] no se pudo refrescar la sesion: $e');
    }
  }
}

final accountProvider =
    AsyncNotifierProvider<AccountNotifier, Session?>(AccountNotifier.new);

/// Todos los planes, para subir el diario completo.
final allPlansProvider = StreamProvider<List<DayPlan>>((ref) => ref
    .watch(planRepositoryProvider)
    .watchRange(DateTime(2000), DateTime(2100)));

class SyncState {
  const SyncState({
    this.running = false,
    this.restoring = false,
    this.lastAt,
    this.error,
  });
  final bool running;

  /// Bajando el armario de la nube a un movil vacio.
  final bool restoring;
  final DateTime? lastAt;
  final String? error;
}

class SyncNotifier extends Notifier<SyncState> {
  Timer? _debounce;

  @override
  SyncState build() {
    ref.onDispose(() => _debounce?.cancel());
    // Cualquier cambio en lo que se sube programa una sincronizacion. Con
    // espera, para que diez cambios seguidos (una tanda de prendas) sean una
    // sola subida y no diez.
    void schedule(_, _) => _scheduleSoon();
    ref.listen(fullWardrobeProvider, schedule);
    ref.listen(savedOutfitsProvider, schedule);
    ref.listen(allPlansProvider, schedule);
    ref.listen(accountProvider, schedule);
    return const SyncState();
  }

  void _scheduleSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 20), syncNow);
  }

  Future<void> syncNow() async {
    if (state.running) return;
    final session = ref.read(accountProvider).value;
    if (session == null) return;
    state = SyncState(running: true, lastAt: state.lastAt);
    try {
      final storage = await ref.read(imageStorageProvider.future);
      final api = ref.read(convexProvider);

      // Movil vacio y nube con prendas: es una reinstalacion o un movil
      // nuevo. Se baja el armario en vez de subir el vacio, que lo borraria.
      final local = await ref
          .read(garmentRepositoryProvider)
          .getAll(includeArchived: true);
      if (local.isEmpty) {
        final restore = ClosetRestore(
          api: api,
          storage: storage,
          garments: ref.read(garmentRepositoryProvider),
          catalog: ref.read(catalogRepositoryProvider),
          outfits: ref.read(outfitRepositoryProvider),
          plans: ref.read(planRepositoryProvider),
        );
        if (await restore.remoteCount() > 0) {
          state = SyncState(running: true, restoring: true, lastAt: state.lastAt);
          final n = await restore.restore(session.closetId);
          debugPrint('[ivy] restauradas $n prendas desde la nube');
        }
      }

      await ClosetSync(api: ref.read(convexProvider), storage: storage).push(
        garments: await ref
            .read(garmentRepositoryProvider)
            .getAll(includeArchived: true),
        outfits: await ref.read(savedOutfitsProvider.future),
        plans: await ref.read(allPlansProvider.future),
      );
      state = SyncState(lastAt: DateTime.now());
    } catch (e) {
      debugPrint('[ivy] sincronizacion fallo: $e');
      state = SyncState(lastAt: state.lastAt, error: '$e');
    }
  }
}

final syncProvider =
    NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);
