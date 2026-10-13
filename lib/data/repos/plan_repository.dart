import 'package:drift/drift.dart';

import '../../domain/models/garment.dart';
import '../../domain/models/outfit.dart';
import '../../domain/outfit/wear_history.dart';
import '../db/database.dart';
import 'garment_repository.dart';
import 'outfit_repository.dart';

/// Una opción planificada para un día.
///
/// Un día admite varias: planificar es barajar alternativas, y al llegar el
/// día se marca cuál se llevó de verdad.
class DayPlan {
  const DayPlan({
    required this.id,
    required this.day,
    required this.items,
    this.outfit,
    this.notes,
    this.wasWorn = false,
    this.photoPath,
  });

  final int id;

  /// Siempre a medianoche. Ver [PlanRepository.dayKey].
  final DateTime day;

  /// Las prendas del plan, vengan de un outfit guardado o sueltas.
  final List<Garment> items;

  /// El outfit guardado del que salió, si vino de uno.
  final SavedOutfit? outfit;

  final String? notes;

  /// Confirmado como puesto de verdad, no solo planificado.
  final bool wasWorn;

  /// Foto del look, ruta relativa. Ver `OutfitPlans.photoPath`.
  final String? photoPath;

  String get title => outfit?.displayName ?? 'Plan';
}

class PlanRepository {
  PlanRepository(this._db, this._garments, this._outfits);

  final AppDatabase _db;
  final GarmentRepository _garments;
  final OutfitRepository _outfits;

  /// Normaliza una fecha a medianoche local.
  ///
  /// Todo lo que entra y sale del calendario pasa por aquí: sin esto, dos
  /// planes del mismo martes con horas distintas serían días distintos.
  static DateTime dayKey(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // ---- lectura -----------------------------------------------------------

  /// Planes en un rango de fechas, ambos extremos incluidos.
  Stream<List<DayPlan>> watchRange(DateTime from, DateTime to) {
    final start = dayKey(from);
    final end = dayKey(to);
    final q = _db.select(_db.outfitPlans)
      ..where((t) => t.day.isBiggerOrEqualValue(start))
      ..where((t) => t.day.isSmallerOrEqualValue(end))
      ..orderBy([
        (t) => OrderingTerm.asc(t.day),
        // Lo que se llevó de verdad arriba: al mirar atrás es lo que importa.
        (t) => OrderingTerm.desc(t.wasWorn),
        (t) => OrderingTerm.asc(t.id),
      ]);
    return q.watch().asyncMap(_hydrate);
  }

  /// Todas las opciones de un día.
  Future<List<DayPlan>> forDay(DateTime date) async {
    final rows = await (_db.select(_db.outfitPlans)
          ..where((t) => t.day.equals(dayKey(date)))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return _hydrate(rows);
  }

  /// El historial de lo que se llevó puesto, para que el motor no repita.
  ///
  /// Solo cuentan los planes marcados como puestos: lo planificado y no
  /// confirmado es una intención, no un hecho, y tratarlo como hecho haría
  /// que el motor descartase ropa que en realidad nunca saliste con ella.
  Future<WearHistory> wearHistory({int lastDays = 120}) async {
    final since = dayKey(DateTime.now().subtract(Duration(days: lastDays)));

    final rows = await (_db.select(_db.outfitPlans)
          ..where((t) => t.wasWorn.equals(true))
          ..where((t) => t.day.isBiggerOrEqualValue(since)))
        .get();
    if (rows.isEmpty) return WearHistory.empty;

    final plans = await _hydrate(rows);
    return WearHistory([
      for (final p in plans)
        if (p.items.isNotEmpty)
          WearEntry(
            day: p.day,
            garmentIds: p.items.map((g) => g.id).toSet(),
            outfitId: p.outfit?.id,
          ),
    ]);
  }

  // ---- escritura ---------------------------------------------------------

  /// Añade una opción a un día. No reemplaza lo que ya hubiera.
  Future<int> addPlan(
    DateTime date, {
    SavedOutfit? outfit,
    List<Garment> garments = const [],
    String? notes,
  }) {
    return _db.transaction(() async {
      final id = await _db.into(_db.outfitPlans).insert(
            OutfitPlansCompanion.insert(
              day: dayKey(date),
              outfitId: Value(outfit?.id),
              notes: Value(notes),
              createdAt: DateTime.now(),
            ),
          );

      // Las prendas sueltas solo se guardan si no viene de un outfit: si
      // viniera, duplicar la lista abriría la puerta a que se
      // desincronizaran cuando el outfit se edite.
      if (outfit == null && garments.isNotEmpty) {
        await _db.batch((b) {
          b.insertAll(
            _db.planItems,
            garments
                .map((g) =>
                    PlanItemsCompanion.insert(planId: id, garmentId: g.id))
                .toList(),
            mode: InsertMode.insertOrIgnore,
          );
        });
      }
      return id;
    });
  }

  /// Deja el día con una sola opción, la indicada.
  Future<int> replaceDay(
    DateTime date, {
    SavedOutfit? outfit,
    List<Garment> garments = const [],
    String? notes,
  }) async {
    await clearDay(date);
    return addPlan(date, outfit: outfit, garments: garments, notes: notes);
  }

  Future<void> removePlan(int planId) =>
      (_db.delete(_db.outfitPlans)..where((t) => t.id.equals(planId))).go();

  Future<void> clearDay(DateTime date) =>
      (_db.delete(_db.outfitPlans)..where((t) => t.day.equals(dayKey(date))))
          .go();

  /// Confirma que una opción concreta se llevó puesta.
  ///
  /// Marcar una desmarca las demás del mismo día: solo se puede llevar un
  /// conjunto a la vez, y permitir dos falsearía el historial que usa el
  /// motor para no repetir.
  Future<void> markWorn(int planId) async {
    await _db.transaction(() async {
      final plan = await (_db.select(_db.outfitPlans)
            ..where((t) => t.id.equals(planId)))
          .getSingleOrNull();
      if (plan == null || plan.wasWorn) return;

      await (_db.update(_db.outfitPlans)
            ..where((t) => t.day.equals(plan.day) & t.id.equals(planId).not()))
          .write(const OutfitPlansCompanion(wasWorn: Value(false)));

      await (_db.update(_db.outfitPlans)..where((t) => t.id.equals(planId)))
          .write(const OutfitPlansCompanion(wasWorn: Value(true)));

      // El uso se propaga a las prendas: es lo que alimenta la rotación.
      final hydrated = (await _hydrate([plan])).firstOrNull;
      if (hydrated == null) return;

      final outfit = hydrated.outfit;
      if (outfit != null) {
        await _outfits.markWorn(outfit.id, when: plan.day);
      } else {
        for (final g in hydrated.items) {
          await _garments.markWorn(g.id, when: plan.day);
        }
      }
    });
  }

  /// Pone o quita la foto del look. Devuelve la que habia, para que quien
  /// llama borre el fichero: este repositorio no conoce el disco.
  Future<String?> setPhoto(int planId, String? relativePath) async {
    final row = await (_db.select(_db.outfitPlans)
          ..where((t) => t.id.equals(planId)))
        .getSingleOrNull();
    await (_db.update(_db.outfitPlans)..where((t) => t.id.equals(planId)))
        .write(OutfitPlansCompanion(photoPath: Value(relativePath)));
    return row?.photoPath;
  }

  /// Fotos de looks referenciadas. Las necesita el barrido de huerfanos: sin
  /// ellas las borraria como si fueran basura.
  Future<Set<String>> allPhotoPaths() async {
    final rows = await (_db.select(_db.outfitPlans)
          ..where((t) => t.photoPath.isNotNull()))
        .get();
    return {for (final r in rows) r.photoPath!};
  }

  Future<void> unmarkWorn(int planId) =>
      (_db.update(_db.outfitPlans)..where((t) => t.id.equals(planId)))
          .write(const OutfitPlansCompanion(wasWorn: Value(false)));

  /// Planifica varios días de golpe.
  ///
  /// Es lo que hace útil planificar: organizar la semana entera de una
  /// sentada, no día a día. Cada día recibe una sola opción y se reemplaza
  /// lo que hubiera, porque quien planifica una semana espera empezar de
  /// cero.
  Future<void> planDays(Map<DateTime, List<Garment>> byDay) async {
    await _db.transaction(() async {
      for (final entry in byDay.entries) {
        if (entry.value.isEmpty) continue;
        await replaceDay(entry.key, garments: entry.value);
      }
    });
  }

  Future<List<DayPlan>> _hydrate(List<PlanRow> rows) async {
    if (rows.isEmpty) return const [];

    // Una sola carga de outfits y prendas para todos los planes del rango.
    final outfitIds = rows.map((r) => r.outfitId).nonNulls.toSet();
    final outfitsById = outfitIds.isEmpty
        ? const <int, SavedOutfit>{}
        : {
            for (final o in await _outfits.watchAll().first)
              if (outfitIds.contains(o.id)) o.id: o,
          };

    final links = await (_db.select(_db.planItems)
          ..where((t) => t.planId.isIn(rows.map((r) => r.id).toList())))
        .get();
    final neededGarments = links.map((l) => l.garmentId).toSet();
    final garmentsById = neededGarments.isEmpty
        ? const <int, Garment>{}
        : {
            for (final g in await _garments.getAll(includeArchived: true))
              if (neededGarments.contains(g.id)) g.id: g,
          };

    final looseByPlan = <int, List<Garment>>{};
    for (final l in links) {
      final g = garmentsById[l.garmentId];
      if (g != null) looseByPlan.putIfAbsent(l.planId, () => []).add(g);
    }

    return rows.map((r) {
      final outfit = r.outfitId == null ? null : outfitsById[r.outfitId];
      return DayPlan(
        id: r.id,
        day: r.day,
        // Un plan que apuntaba a un outfit borrado se queda sin prendas pero
        // no desaparece: el usuario ve el hueco y decide.
        items: outfit?.items ?? looseByPlan[r.id] ?? const [],
        outfit: outfit,
        notes: r.notes,
        wasWorn: r.wasWorn,
        photoPath: r.photoPath,
      );
    }).toList();
  }
}
