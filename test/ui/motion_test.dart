import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/ui/design/motion.dart';

/// La transicion entre pantallas tuvo un fallo que no se ve leyendo el
/// codigo: el desenfoque de entrada estaba, pero la opacidad subia a la vez,
/// asi que la pantalla era casi transparente justo mientras estaba borrosa.
/// No se veia entrar nada, se veia un salto. El orden es la funcionalidad.
void main() {
  late AnimationController controller;

  Future<void> mount(WidgetTester tester) async {
    controller = AnimationController(vsync: tester, value: 0);
    await tester.pumpWidget(
      MaterialApp(
        home: IvyReveal(
          animation: controller,
          child: const SizedBox(width: 10, height: 10, key: Key('contenido')),
        ),
      ),
    );
  }

  double opacity(WidgetTester tester) =>
      tester.widget<Opacity>(find.byType(Opacity).first).opacity;

  bool blurred(WidgetTester tester) =>
      find.byType(ImageFiltered).evaluate().isNotEmpty;

  testWidgets('a mitad de camino ya es opaca pero sigue desenfocada', (
    tester,
  ) async {
    await mount(tester);
    controller.value = 0.5;
    await tester.pump();

    expect(
      opacity(tester),
      1.0,
      reason: 'si aun es translucida no se ve la fase desenfocada',
    );
    expect(
      blurred(tester),
      isTrue,
      reason: 'sin desenfoque a media transicion no hay entrada, hay corte',
    );
  });

  testWidgets('al terminar no queda filtro puesto', (tester) async {
    await mount(tester);
    controller.value = 1;
    await tester.pump();

    expect(opacity(tester), 1.0);
    expect(
      blurred(tester),
      isFalse,
      reason: 'una capa de filtro en reposo se paga en cada fotograma',
    );
  });

  testWidgets('el contenido no se desmonta cuando la opacidad es cero', (
    tester,
  ) async {
    await mount(tester);
    await tester.pump();

    // Quitarlo del arbol destruiria el estado de la pantalla entrante.
    expect(find.byKey(const Key('contenido')), findsOneWidget);
    expect(opacity(tester), 0.0);
    expect(
      blurred(tester),
      isFalse,
      reason: 'desenfocar lo invisible no pinta',
    );
  });

  testWidgets('la pantalla tapada se desenfoca y se aleja', (tester) async {
    final secondary = AnimationController(vsync: tester, value: 1);
    await tester.pumpWidget(
      MaterialApp(
        home: IvyReveal(
          animation: kAlwaysCompleteAnimation,
          secondaryAnimation: secondary,
          child: const SizedBox(width: 10, height: 10),
        ),
      ),
    );

    expect(blurred(tester), isTrue);
    expect(opacity(tester), lessThan(1.0));
    // `getMaxScaleOnAxis` no sirve aqui: el eje z se queda en 1 y devuelve
    // el maximo de los tres. La escala del plano esta en storage[0].
    final scales = tester
        .widgetList<Transform>(find.byType(Transform))
        .map((t) => t.transform.storage[0]);
    expect(
      scales.any((s) => s < 1.0),
      isTrue,
      reason: 'la de abajo se va hacia atras',
    );
  });

  group('cambio de pestana', _slideTests);
}

/// Al cambiar de pestana el enrutador **reemplaza** la pagina, y Flutter no
/// despide a la que quita: la elimina. Su animacion de salida no corre nunca.
/// Por eso el cambio no puede vivir en la ruta y vive en este widget, que
/// tiene las dos pantallas a la vez.
void _slideTests() {
  // `skipOffstage: false` en todos los buscadores: por defecto el test no ve
  // lo que esta fuera de pantalla, que es justo lo que hay que comprobar.
  Finder capa(String text, Type tipo) => find
      .ancestor(
        of: find.text(text, skipOffstage: false),
        matching: find.byType(tipo, skipOffstage: false),
      )
      .first;

  double offsetOf(WidgetTester tester, String text) =>
      tester.widget<Transform>(capa(text, Transform)).transform.storage[12];

  bool shown(WidgetTester tester, String text) =>
      !tester.widget<Offstage>(capa(text, Offstage)).offstage;

  Future<void> mount(WidgetTester tester, int index) => tester.pumpWidget(
    MaterialApp(
      home: IvyTabSwitcher(
        index: index,
        children: const [Text('A'), Text('B'), Text('C')],
      ),
    ),
  );

  testWidgets('en reposo solo se ve la pestana actual', (tester) async {
    await mount(tester, 0);
    expect(shown(tester, 'A'), isTrue);
    expect(shown(tester, 'B'), isFalse);
    expect(offsetOf(tester, 'A'), 0);
  });

  testWidgets('durante el cambio las dos se mueven y van pegadas', (
    tester,
  ) async {
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    await mount(tester, 0);
    await mount(tester, 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(shown(tester, 'A'), isTrue, reason: 'la que sale sigue en pantalla');
    expect(shown(tester, 'B'), isTrue);

    final salida = offsetOf(tester, 'A');
    final entrada = offsetOf(tester, 'B');
    expect(salida, lessThan(0), reason: 'se va por la izquierda');
    expect(entrada, greaterThan(0), reason: 'entra por la derecha');
    expect(
      entrada - salida,
      closeTo(width, 0.01),
      reason: 'separadas justo un ancho: ni rendija ni solape',
    );

    await tester.pumpAndSettle();
    expect(offsetOf(tester, 'B'), 0);
    expect(shown(tester, 'A'), isFalse);
  });

  testWidgets('hacia atras se mueve al reves', (tester) async {
    await mount(tester, 2);
    await mount(tester, 0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(
      offsetOf(tester, 'A'),
      lessThan(0),
      reason: 'entra por la izquierda',
    );
    expect(
      offsetOf(tester, 'C'),
      greaterThan(0),
      reason: 'sale por la derecha',
    );
  });

  testWidgets('las pestanas que no participan siguen vivas', (tester) async {
    await mount(tester, 0);
    await mount(tester, 1);
    await tester.pump();

    // Ni se pintan ni se mueven, pero no se desmontan: es lo que conserva su
    // posicion de scroll.
    expect(find.text('C', skipOffstage: false), findsOneWidget);
    expect(shown(tester, 'C'), isFalse);
    expect(offsetOf(tester, 'C'), 0);
  });
}
