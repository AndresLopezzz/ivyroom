import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ivyroom/ui/design/motion.dart';

/// La forma de las rutas de las pestanas, aparte del widget que las mueve.
///
/// El fallo que llevo a esto no estaba en la animacion sino aqui: con un
/// `ShellRoute` normal, cambiar de pestana **reemplaza** la pagina, y Flutter
/// no despide a la que quita —la elimina—, asi que su salida no se animaba y
/// las dos se veian encimadas. Con ramas, las cuatro siguen vivas.
void main() {
  late GoRouter router;

  Widget build() {
    router = GoRouter(
      initialLocation: '/a',
      routes: [
        StatefulShellRoute(
          builder: (_, _, shell) => Scaffold(body: shell),
          navigatorContainerBuilder: (_, shell, children) =>
              IvyTabSwitcher(index: shell.currentIndex, children: children),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/a', builder: (_, _) => const _Contador('A')),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/b', builder: (_, _) => const _Contador('B')),
              ],
            ),
          ],
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('las dos pestanas se mueven durante el cambio', (tester) async {
    await tester.pumpWidget(build());
    router.go('/b');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    double dx(String t) => tester
        .widget<Transform>(
          find
              .ancestor(
                of: find.textContaining(t, skipOffstage: false),
                matching: find.byType(Transform, skipOffstage: false),
              )
              .first,
        )
        .transform
        .storage[12];

    expect(
      dx('A'),
      lessThan(0),
      reason: 'la que sale tiene que salir, no quedarse quieta debajo',
    );
    expect(dx('B'), greaterThan(0));

    await tester.pumpAndSettle();
    expect(dx('B'), 0);
  });

  testWidgets('una pestana conserva su estado al volver', (tester) async {
    await tester.pumpWidget(build());
    await tester.tap(find.text('A 0'));
    await tester.pump();
    expect(find.text('A 1'), findsOneWidget);

    router.go('/b');
    await tester.pumpAndSettle();
    router.go('/a');
    await tester.pumpAndSettle();

    expect(
      find.text('A 1'),
      findsOneWidget,
      reason: 'volver a una pestana es volver a donde la dejaste',
    );
  });
}

class _Contador extends StatefulWidget {
  const _Contador(this.nombre);
  final String nombre;

  @override
  State<_Contador> createState() => _ContadorState();
}

class _ContadorState extends State<_Contador> {
  int _n = 0;

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: () => setState(() => _n++),
      child: Text('${widget.nombre} $_n'),
    ),
  );
}
