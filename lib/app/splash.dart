import 'package:flutter/material.dart';

import '../ui/design/motion.dart';
import '../ui/design/tokens.dart';

/// La entrada de la app.
///
/// Cubre el arranque real: mientras corre, por debajo ya se esta abriendo la
/// base de datos y resolviendo los proveedores. No es tiempo muerto anadido,
/// es tiempo que ya se iba a pasar mirando algo —y ese algo era una pantalla
/// en blanco.
///
/// El logotipo entra con el mismo lenguaje que el resto de la app: llega
/// desenfocado y enfoca. Por eso reutiliza [IvyReveal] literalmente en vez de
/// inventarse una animacion propia; una app que se presenta de una forma y
/// luego se mueve de otra se siente cosida de dos trozos.
class IvySplash extends StatefulWidget {
  const IvySplash({super.key, required this.child});

  final Widget child;

  static const _total = Duration(milliseconds: 2000);

  /// El logotipo enfoca en el primer 45 %, se queda quieto hasta el 68 %, y
  /// el resto es el papel disolviendose.
  static const _entrada = Interval(0, 0.45);
  static const _salida = Interval(0.68, 1, curve: IvyMotion.curve);

  @override
  State<IvySplash> createState() => _IvySplashState();
}

class _IvySplashState extends State<IvySplash>
    with SingleTickerProviderStateMixin {
  static const _logo = AssetImage('assets/branding/wordmark.png');

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: IvySplash._total,
  )..addStatusListener((status) {
      // Se quita al completarse, venga de donde venga: un toque que la salta
      // puede terminar antes de que la precarga del logotipo haya vuelto.
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _fuera = true);
      }
    });

  late final Animation<double> _entrada = CurvedAnimation(
    parent: _c,
    curve: IvySplash._entrada,
  );

  bool _arrancado = false;
  bool _fuera = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_arrancado) return;
    _arrancado = true;
    _arrancar();
  }

  /// Espera a tener el PNG decodificado antes de empezar —si no, el primer
  /// fotograma de la animacion es un hueco y el logotipo aparece tarde, en
  /// mitad de su propia entrada— pero **con un tope**.
  ///
  /// Sin ese tope, un asset que no carga deja la app tapada para siempre.
  /// Una pantalla de bienvenida no puede ser un punto de fallo: como mucho
  /// se ve un parpadeo, nunca una app que no arranca.
  Future<void> _arrancar() async {
    await precacheImage(_logo, context)
        .timeout(const Duration(milliseconds: 400), onTimeout: () {})
        .catchError((_) {});
    if (!mounted || _c.isCompleted) return;
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Una vez terminada desaparece del arbol: no tiene sentido pagar una
        // capa a pantalla completa durante toda la vida de la app.
        if (!_fuera)
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) => _velo(context),
          ),
      ],
    );
  }

  Widget _velo(BuildContext context) {
    final salida = IvySplash._salida.transform(_c.value);
    final ancho = MediaQuery.sizeOf(context).width;

    return IgnorePointer(
      // Deja de tragarse los toques en cuanto es mas transparente que opaca:
      // bloquear una capa que ya casi no se ve solo consigue que el primer
      // toque de la sesion no haga nada.
      ignoring: salida > 0.5,
      child: Opacity(
        opacity: 1 - salida,
        child: GestureDetector(
          // Saltarsela. Dos segundos son pocos la primera vez y muchos la
          // vigesima, y quien ya sabe lo que pone ahi no tiene por que
          // esperar.
          onTap: () => _c.animateTo(1, duration: IvyMotion.normal),
          child: ColoredBox(
            color: Ivy.paper,
            child: Center(
              child: Transform.scale(
                // Al irse crece un poco: el papel se levanta hacia ti, que es
                // el mismo gesto con el que entra cualquier pantalla.
                scale: 1 + salida * 0.08,
                child: IvyReveal(
                  animation: _entrada,
                  child: Image(
                    image: _logo,
                    width: (ancho * 0.56).clamp(160.0, 260.0),
                    // El PNG es blanco con alfa: la tinta la pone el tema.
                    color: Ivy.ink,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
