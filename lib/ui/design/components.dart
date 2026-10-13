import 'dart:ui';

import 'package:flutter/material.dart';

import 'motion.dart';
import 'tokens.dart';
import 'type.dart';

/// Tarjeta blanca sobre papel.
///
/// Separa por **valor**, no por sombra: blanco sobre papel cálido ya crea
/// jerarquía, y llenar la pantalla de sombras es lo que hace que una
/// interfaz parezca hecha con plantilla.
class IvyCard extends StatelessWidget {
  const IvyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Ivy.s4),
    this.onTap,
    this.radius = Ivy.rCard,
    this.color = Ivy.surface,
    this.border = false,
    this.shadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Color color;
  final bool border;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: border ? Border.all(color: Ivy.hairline) : null,
          boxShadow: shadow,
        ),
        child: child,
      ),
    );
  }
}

/// La tarjeta negra.
///
/// Hay **una por pantalla como mucho**. Es el ancla de contraste: lo que
/// importa de verdad en esta pantalla. Si hubiera dos, no habría ninguna.
class InkCard extends StatelessWidget {
  const InkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Ivy.s5),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Ivy.ink,
          borderRadius: BorderRadius.circular(Ivy.rCard),
        ),
        child: DefaultTextStyle(
          style: IvyType.body.copyWith(color: Ivy.surface),
          child: child,
        ),
      ),
    );
  }
}

/// Píldora. Sirve de filtro, de etiqueta y de botón secundario.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.onDelete,
    this.tone = PillTone.neutral,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final PillTone tone;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch ((selected, tone)) {
      (true, _) => (Ivy.ink, Ivy.surface),
      (false, PillTone.neutral) => (Ivy.paper, Ivy.inkSoft),
      (false, PillTone.onSurface) => (const Color(0xFFF1EFEA), Ivy.inkSoft),
      (false, PillTone.sage) => (Ivy.sageSoft, Ivy.sage),
      (false, PillTone.clay) => (Ivy.claySoft, Ivy.clay),
    };

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: IvyMotion.fast,
        curve: IvyMotion.curve,
        padding: EdgeInsets.symmetric(
          horizontal: dense ? Ivy.s3 : Ivy.s4,
          vertical: dense ? 6 : Ivy.s2 + 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Ivy.rPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: dense ? 13 : 15, color: fg),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: (dense ? IvyType.smallStrong : IvyType.action)
                  .copyWith(color: fg),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close_rounded, size: 14, color: fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum PillTone { neutral, onSurface, sage, clay }

/// Botón principal: tinta sólida, forma de píldora.
class InkButton extends StatelessWidget {
  const InkButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.expand = true,
    this.tone = InkButtonTone.ink,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool expand;
  final InkButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final (bg, fg) = switch (tone) {
      InkButtonTone.ink => (Ivy.ink, Ivy.surface),
      InkButtonTone.paper => (Ivy.surface, Ivy.ink),
      InkButtonTone.sage => (Ivy.sage, Ivy.surface),
    };

    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
              horizontal: Ivy.s5, vertical: Ivy.s4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(Ivy.rPill),
            boxShadow: tone == InkButtonTone.paper ? Ivy.lifted : null,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: Ivy.s2),
              ],
              Text(label, style: IvyType.action.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

enum InkButtonTone { ink, paper, sage }

/// Botón circular de icono, para la barra superior.
class GlyphButton extends StatelessWidget {
  const GlyphButton({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.badge = false,
    this.filled = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool badge;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final button = Pressable(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: filled ? Ivy.surface : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: Ivy.ink),
            if (badge)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Ivy.clay,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Etiqueta de sección.
///
/// Se escribe tal cual venga, en minúscula: nada de convertir a mayúsculas
/// ni de abrir el tracking.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Ivy.gutter, Ivy.s5, Ivy.gutter, Ivy.s3),
      child: Row(
        children: [
          Expanded(child: Text(text, style: IvyType.labelFaint)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Barra flotante translúcida.
///
/// El contenido pasa por debajo en vez de quedarse cortado por una barra
/// opaca: es lo que hace que la pantalla se sienta más alta de lo que es.
class GlassBar extends StatelessWidget {
  const GlassBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(Ivy.gutter, Ivy.s2, Ivy.gutter, Ivy.s3),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          color: Ivy.paper.withValues(alpha: 0.72),
          child: child,
        ),
      ),
    );
  }
}

/// Degradado corto donde el contenido se cruza con la barra flotante.
///
/// Sustituye a la típica línea de 1px: el borde duro corta la pantalla, el
/// desvanecido deja ver que hay más contenido debajo.
class ScrollEdge extends StatelessWidget {
  const ScrollEdge({super.key, this.height = 28, this.reversed = false});

  final double height;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: reversed ? Alignment.bottomCenter : Alignment.topCenter,
            end: reversed ? Alignment.topCenter : Alignment.bottomCenter,
            colors: [Ivy.paper, Ivy.paper.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

/// Estado vacío. Uno solo para toda la app, para que todos se lean igual.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.body,
    this.action,
  });

  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Ivy.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: IvyType.title, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: Ivy.s3),
              Text(
                body!,
                style: IvyType.body.copyWith(color: Ivy.inkSoft),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: Ivy.s5),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Fondo difuso muy suave.
///
/// Una sola mancha, en un tono apenas distinto del papel. Es lo que da
/// profundidad sin degradados de colores, que son la marca de la casa de las
/// interfaces genéricas.
class PaperGlow extends StatelessWidget {
  const PaperGlow({super.key, this.alignment = const Alignment(0.6, -0.85)});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFE6E2D8).withValues(alpha: 0.9),
                const Color(0xFFE6E2D8).withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
