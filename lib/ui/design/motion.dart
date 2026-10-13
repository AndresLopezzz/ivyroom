import 'dart:ui';

import 'package:flutter/material.dart';

/// Los tiempos y las curvas.
///
/// Una sola fuente para todo lo que se mueve. Si un numero de duracion
/// aparece suelto en una pantalla, esta mal: acaba siendo distinto del de al
/// lado y la interfaz se siente descosida.
class IvyMotion {
  const IvyMotion._();

  /// Reacciones a un toque: escalas, cambios de color.
  static const fast = Duration(milliseconds: 180);

  /// Cambios de estado dentro de una pantalla.
  static const normal = Duration(milliseconds: 320);

  /// Cambio de pestana.
  static const tab = Duration(milliseconds: 420);

  /// Entrar en una pantalla nueva.
  static const enter = Duration(milliseconds: 560);

  /// Volver. Mas corta que la ida: al volver ya sabes lo que hay detras, y
  /// esperar el mismo tiempo por algo conocido se siente lento.
  static const back = Duration(milliseconds: 440);

  /// Salida amortiguada: rapida al principio, frena al llegar. Es como se
  /// mueve cualquier cosa que alguien suelta.
  static const curve = Curves.easeOutCubic;

  /// La misma curva del reves, para lo que se va.
  static const curveIn = Curves.easeInCubic;

  /// Arranca y termina despacio. Para valores que no persiguen un objetivo
  /// sino que atraviesan un rango, como el desenfoque.
  static const curveThrough = Curves.easeInOutCubic;
}

/// Respuesta al toque.
///
/// Se encoge en `onTapDown`, no al soltar: la sensacion de mando directo se
/// cae en cuanto hay latencia, y esperar al `onTap` mete el retardo de
/// deteccion entero antes de dar la primera senal.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.96,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: IvyMotion.fast,
        curve: IvyMotion.curve,
        child: widget.child,
      ),
    );
  }
}

/// El cambio de pantalla: desenfoque y acercamiento.
///
/// No hay un objeto compartido volando de una pantalla a otra. El desenfoque
/// no imita una cosa fisica, imita el **enfoque de la vista**, que es lo que
/// de verdad hace el ojo al cambiar de sitio: lo nuevo llega desenfocado y se
/// resuelve, lo viejo se va perdiendo el foco.
///
/// El detalle que hace que funcione es el **orden**: la opacidad termina de
/// entrar mucho antes que el desenfoque. Si las dos suben a la vez, la
/// pantalla es casi transparente justo mientras esta borrosa, no se ve nada
/// de la fase desenfocada y lo que percibes es un salto seco. Primero
/// aparece, luego enfoca.
class IvyReveal extends StatelessWidget {
  const IvyReveal({
    super.key,
    required this.animation,
    required this.child,
    this.secondaryAnimation,
  });

  final Animation<double> animation;

  /// Progreso con el que esta pantalla queda **tapada** por otra. Sin ella,
  /// la de abajo se queda quieta y nitida y el cambio pierde profundidad.
  final Animation<double>? secondaryAnimation;

  final Widget child;

  /// Cuanto desenfoque, en sigma, tiene la pantalla al aparecer.
  static const _blur = 22.0;

  /// Escala de partida.
  static const _from = 0.94;

  /// La opacidad cierra en el primer 45 % del recorrido; el resto del tiempo
  /// la pantalla ya es opaca y lo unico que queda por pasar es el enfoque.
  static const _fadeEnds = 0.45;

  @override
  Widget build(BuildContext context) {
    final second = secondaryAnimation ?? kAlwaysDismissedAnimation;
    return AnimatedBuilder(
      animation: Listenable.merge([animation, second]),
      builder: (context, _) {
        final t = animation.value.clamp(0.0, 1.0);
        final s = second.value.clamp(0.0, 1.0);

        final appear = IvyMotion.curve.transform(
          (t / _fadeEnds).clamp(0.0, 1.0),
        );
        final focus = IvyMotion.curveThrough.transform(t);
        final settle = IvyMotion.curve.transform(t);
        final cover = IvyMotion.curveThrough.transform(s);

        final sigma = (1 - focus) * _blur + cover * _blur * 0.7;
        final scale = (_from + (1 - _from) * settle) * (1 - cover * 0.05);
        final opacity = appear * (1 - cover * 0.5);

        Widget content = child;
        // El filtro solo se monta cuando hay algo que desenfocar y ademas se
        // ve: dejarlo puesto en reposo cuesta una capa por pantalla para
        // nada. Lo que no se hace es quitar el hijo del arbol cuando la
        // opacidad es cero, porque eso destruiria el estado de la pantalla y
        // la obligaria a reconstruirse entera un fotograma despues.
        if (sigma > 0.1 && opacity > 0.01) {
          content = ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: sigma,
              sigmaY: sigma,
              tileMode: TileMode.decal,
            ),
            child: content,
          );
        }

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(scale: scale, child: content),
        );
      },
    );
  }
}

/// [IvyReveal] como transicion de ruta, para las pantallas que aun se abren
/// con `Navigator.push` directo.
///
/// Ojo: por aqui la duracion la fija Material en 300 ms y no hay forma de
/// cambiarla desde el tema. Las rutas de la app pasan por `ivyPage`, que si
/// la controla.
class IvyPageTransition extends PageTransitionsBuilder {
  const IvyPageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? page,
  ) {
    return IvyReveal(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: page!,
    );
  }
}

/// La misma transicion para un `Navigator.push` suelto, con la duracion
/// correcta en vez de los 300 ms que impone Material.
class IvyRoute<T> extends PageRouteBuilder<T> {
  IvyRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: IvyMotion.enter,
        reverseTransitionDuration: IvyMotion.back,
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, animation, secondary, child) => IvyReveal(
          animation: animation,
          secondaryAnimation: secondary,
          child: child,
        ),
      );
}

/// Cambio de pestana: desplazamiento lateral, sin desenfoque.
///
/// Es un movimiento distinto porque es una **relacion** distinta. Nueva
/// prenda o armar outfit se abren *encima* de donde estabas, y ahi el
/// desenfoque funciona porque hay una pantalla tapando a otra. Las pestanas
/// no se tapan: son cuatro sitios uno al lado del otro, y lo que corresponde
/// es moverse de lado, en el sentido en el que estan puestas en la barra.
///
/// Este widget existe —y no una transicion de ruta— por un motivo concreto:
/// al cambiar de pestana el enrutador **reemplaza** la pagina, y Flutter no
/// despide a la que quita, la elimina. Su animacion de salida no llega a
/// correr nunca, asi que la de fuera se quedaba clavada mientras la nueva
/// entraba por encima. Aqui las dos pantallas estan vivas al mismo tiempo y
/// las mueve el mismo reloj, que es la unica forma de que vayan pegadas.
///
/// De paso las pestanas dejan de destruirse al salir de ellas: vuelves al
/// armario donde lo dejaste, no arriba del todo.
class IvyTabSwitcher extends StatefulWidget {
  const IvyTabSwitcher({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<IvyTabSwitcher> createState() => _IvyTabSwitcherState();
}

class _IvyTabSwitcherState extends State<IvyTabSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: IvyMotion.tab,
    // Arranca en reposo: la primera pestana no entra desde ningun lado.
    value: 1,
  );

  late int _from = widget.index;
  int _direction = 1;

  @override
  void didUpdateWidget(IvyTabSwitcher old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _from = old.index;
      _direction = widget.index > old.index ? 1 : -1;
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = IvyMotion.curve.transform(_c.value);
        final moving = _c.value < 1;
        return Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < widget.children.length; i++)
              _layer(i, t, moving, width),
          ],
        );
      },
    );
  }

  Widget _layer(int i, double t, bool moving, double width) {
    final entering = i == widget.index;
    final leaving = moving && i == _from && _from != widget.index;
    final visible = entering || leaving;

    // La que entra viene desde su lado y llega a cero; la que sale arranca en
    // cero y se va por el contrario. La distancia entre las dos es siempre
    // exactamente un ancho, asi que no se abre ninguna rendija de fondo.
    final dx = entering
        ? (1 - t) * _direction * width
        : -t * _direction * width;

    // La envoltura es identica pinte o no pinte: si cambiaran los tipos de
    // widget segun el caso, Flutter desmontaria la pestana y perderia su
    // posicion de scroll justo al salir de ella.
    return Offstage(
      offstage: !visible,
      child: TickerMode(
        enabled: visible,
        child: Transform.translate(
          offset: Offset(visible ? dx : 0, 0),
          child: widget.children[i],
        ),
      ),
    );
  }
}
