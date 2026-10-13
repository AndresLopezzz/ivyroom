import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/calendar/calendar_screen.dart';
import '../features/capture/batch_capture_screen.dart';
import '../features/capture/capture_flow.dart';
import '../features/closet/catalog_screen.dart';
import '../features/closet/closet_screen.dart';
import '../features/closet/garment_detail_screen.dart';
import '../features/laundry/laundry_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/outfits/outfit_builder_screen.dart';
import '../features/outfits/outfits_screen.dart';
import '../features/outfits/saved_outfits_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/today/today_screen.dart';
import '../features/viewer/viewer_screen.dart';
import '../ui/design/bottom_nav.dart';
import '../ui/design/motion.dart';
import '../ui/design/tokens.dart';
import 'providers.dart';
import 'splash.dart';
import 'theme.dart';

class IvyroomApp extends ConsumerWidget {
  const IvyroomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo se escucha para que arranque y siga vivo: no hay nada que pintar.
    // Las pantallas se enteran solas de las rutas nuevas por los streams de
    // la base.
    ref.listen(imageMigrationProvider, (_, _) {});
    ref.listen(reminderSyncProvider, (_, _) {});
    ref.listen(syncProvider, (_, _) {});
    return MaterialApp.router(
      title: 'Ivyroom',
      theme: buildTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      // Va por encima del enrutador y no dentro de una ruta: mientras se ve
      // la entrada, por debajo ya se esta abriendo la base y resolviendo los
      // proveedores. Como ruta propia, ese trabajo empezaria despues.
      builder: (context, child) => IvySplash(child: child!),
    );
  }
}

/// Una pantalla que se abre **encima** de donde estabas.
///
/// Llega desenfocada y se resuelve, y empuja hacia atras a la de abajo. Es
/// para lo que apila: nueva prenda, armar outfit, estadisticas, ajustes.
///
/// Existe como funcion propia porque `pageTransitionsTheme` **no puede fijar
/// la duracion**: por ahi todo se queda en los 300 ms de Material, que para
/// un desenfoque que tiene que leerse como un enfoque de la vista es
/// demasiado corto. Se nota como un parpadeo en vez de como un movimiento.
CustomTransitionPage<void> ivyPage(Widget child, {required LocalKey key}) {
  return CustomTransitionPage<void>(
    // Sin clave propia go_router reutiliza la pagina entre rutas hermanas y
    // la transicion no llega a correr.
    key: key,
    child: child,
    transitionDuration: IvyMotion.enter,
    // Volver dura menos que ir: ya sabes lo que hay detras.
    reverseTransitionDuration: IvyMotion.back,
    transitionsBuilder: (context, animation, secondary, child) => IvyReveal(
      animation: animation,
      secondaryAnimation: secondary,
      child: child,
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/today',
  routes: [
    // Lo que ocupa la pantalla entera va fuera del shell: no debe ensenar la
    // barra de navegacion.
    GoRoute(
      path: '/capture',
      pageBuilder: (_, s) => ivyPage(const CaptureFlowScreen(), key: s.pageKey),
    ),
    GoRoute(
      path: '/shared/:id',
      pageBuilder: (_, s) => ivyPage(
        ViewerScreen(closetId: s.pathParameters['id']!),
        key: s.pageKey,
      ),
    ),
    GoRoute(
      path: '/welcome',
      pageBuilder: (_, s) => ivyPage(const OnboardingScreen(), key: s.pageKey),
    ),
    GoRoute(
      path: '/capture-batch',
      pageBuilder: (_, s) =>
          ivyPage(const BatchCaptureScreen(), key: s.pageKey),
    ),
    GoRoute(
      path: '/calendar',
      pageBuilder: (_, s) => ivyPage(const CalendarScreen(), key: s.pageKey),
    ),
    GoRoute(
      path: '/build-outfit',
      pageBuilder: (_, s) =>
          ivyPage(const OutfitBuilderScreen(), key: s.pageKey),
    ),
    GoRoute(
      path: '/saved',
      pageBuilder: (_, s) =>
          ivyPage(const SavedOutfitsScreen(), key: s.pageKey),
    ),
    GoRoute(
      path: '/stats',
      pageBuilder: (_, s) => ivyPage(const StatsScreen(), key: s.pageKey),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (_, s) => ivyPage(const SettingsScreen(), key: s.pageKey),
    ),
    GoRoute(
      path: '/catalog',
      pageBuilder: (_, s) => ivyPage(const CatalogScreen(), key: s.pageKey),
    ),
    GoRoute(
      path: '/garment/:id',
      pageBuilder: (_, s) => ivyPage(
        GarmentDetailScreen(garmentId: int.parse(s.pathParameters['id']!)),
        key: s.pageKey,
      ),
    ),
    // `StatefulShellRoute` y no `ShellRoute`: cada pestana conserva su propio
    // navegador y su estado. Ademas es lo que deja tener las dos pantallas
    // vivas a la vez durante el cambio, sin lo cual la que sale no se puede
    // animar (al reemplazar, Flutter la elimina en seco).
    StatefulShellRoute(
      builder: (_, _, shell) => _Shell(shell: shell),
      navigatorContainerBuilder: (_, shell, children) =>
          IvyTabSwitcher(index: shell.currentIndex, children: children),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/closet', builder: (_, _) => const ClosetScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/outfits', builder: (_, _) => const OutfitsScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/laundry', builder: (_, _) => const LaundryScreen()),
          ],
        ),
      ],
    ),
  ],
);

/// Nombres concretos y no paraguas vagos: "Hoy" dice que hay dentro,
/// "Inicio" no diria nada.
///
/// El calendario sale de la barra y se alcanza desde la tira de la semana en
/// Hoy, que es donde uno lo busca de verdad. Cinco pestanas serian una de
/// mas.
const _navItems = [
  NavItem(Icons.today_outlined, Icons.today, 'Hoy', '/today'),
  NavItem(
    Icons.grid_view_outlined,
    Icons.grid_view_rounded,
    'Armario',
    '/closet',
  ),
  NavItem(
    Icons.auto_awesome_outlined,
    Icons.auto_awesome,
    'Outfits',
    '/outfits',
  ),
  NavItem(
    Icons.local_laundry_service_outlined,
    Icons.local_laundry_service,
    'Lavado',
    '/laundry',
  ),
];

class _Shell extends ConsumerStatefulWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<_Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<_Shell> {
  late final AppLifecycleListener _lifecycle;

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Al volver a la app se refresca la sesion: asi aparece un armario que
    // te acaban de compartir sin tener que cerrarla.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(accountProvider.notifier).refresh(),
    );
    // La bienvenida se decide aqui y no en el enrutador: las preferencias
    // se leen de disco, y un `redirect` sincrono no puede esperarlas.
    ref.listenManual(appPrefsProvider, (_, next) {
      final prefs = next.value;
      if (prefs == null || prefs.onboarded) return;
      // Fuera del build: navegar mientras se construye el shell revienta.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/welcome');
      });
    }, fireImmediately: true);
  }

  StatefulNavigationShell get shell => widget.shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ivy.paper,
      // El contenido corre por debajo de la barra flotante.
      extendBody: true,
      body: shell,
      bottomNavigationBar: IvyBottomNav(
        items: _navItems,
        index: shell.currentIndex,
        // `initialLocation` solo cuando se toca la pestana en la que ya
        // estas: eso la devuelve a su raiz, que es lo que espera cualquiera
        // que vuelva a pulsar donde ya esta.
        onSelect: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        onAdd: () => context.push('/capture'),
      ),
    );
  }
}
