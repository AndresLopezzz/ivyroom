import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/app/splash.dart';

void main() {
  Future<void> mount(WidgetTester tester) => tester.pumpWidget(
    const MaterialApp(
      home: IvySplash(child: Scaffold(body: Text('LA APP'))),
    ),
  );

  // Se busca por el logotipo y no por el `ColoredBox`: el `Scaffold` de
  // debajo tiene el suyo y encontraria dos.
  final velo = find.image(const AssetImage('assets/branding/wordmark.png'));

  bool hayVelo(WidgetTester tester) => velo.evaluate().isNotEmpty;

  testWidgets('tapa la app al arrancar y se quita sola', (tester) async {
    await mount(tester);
    await tester.pump();
    expect(hayVelo(tester), isTrue);

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    // No basta con que sea transparente: una capa a pantalla completa que se
    // queda para siempre se paga en cada fotograma de la vida de la app.
    expect(hayVelo(tester), isFalse);
    expect(find.text('LA APP'), findsOneWidget);
  });

  testWidgets('un toque la salta', (tester) async {
    await mount(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tapAt(tester.getCenter(velo));
    await tester.pumpAndSettle();

    expect(
      hayVelo(tester),
      isFalse,
      reason: 'dos segundos son pocos la primera vez y muchos la vigesima',
    );
  });

  testWidgets('la app se construye por debajo desde el primer fotograma', (
    tester,
  ) async {
    await mount(tester);
    await tester.pump();

    // Es lo que hace que la entrada no sea tiempo muerto: la base de datos y
    // los proveedores arrancan mientras se ve el logotipo.
    expect(find.text('LA APP', skipOffstage: false), findsOneWidget);

    // Deja vencer el tope de precarga y la animacion: si no, el test acaba
    // con temporizadores pendientes.
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
  });
}
