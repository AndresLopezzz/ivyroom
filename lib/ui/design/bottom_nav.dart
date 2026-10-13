import 'dart:ui';

import 'package:flutter/material.dart';

import 'motion.dart';
import 'tokens.dart';

class NavItem {
  const NavItem(this.icon, this.activeIcon, this.label, this.route);
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

/// Barra inferior flotante.
///
/// Compacta y centrada en vez de ocupar todo el ancho: una barra de borde a
/// borde parte la pantalla en dos y hace que el contenido termine ahí. Esta
/// se lee como un mando que flota encima, y deja ver que la lista sigue por
/// debajo.
///
/// Solo iconos. La etiqueta se cae porque con cuatro destinos y nombres de
/// una palabra el icono ya basta, y el texto obligaba a ensanchar la barra
/// hasta comerse los márgenes.
class IvyBottomNav extends StatelessWidget {
  const IvyBottomNav({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
    required this.onAdd,
  });

  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  /// Añadir prenda. Vive en el centro de la barra y no en un botón suelto
  /// porque es la acción que alimenta todo lo demás: sin prendas, ninguna de
  /// las cuatro pestañas tiene nada que enseñar.
  final VoidCallback onAdd;

  static const _slot = 52.0;
  static const _height = 60.0;

  @override
  Widget build(BuildContext context) {
    // El "+" parte los destinos por la mitad: dos a cada lado.
    final half = items.length ~/ 2;
    final left = items.sublist(0, half);
    final right = items.sublist(half);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + Ivy.s3,
      ),
      // Una fila y no un `Center`: dentro del hueco de `bottomNavigationBar`
      // las restricciones son sueltas, y `Center` se estira a toda la altura
      // disponible dejando la barra flotando en mitad de la pantalla.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
          borderRadius: BorderRadius.circular(Ivy.rPill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: _height,
              padding: const EdgeInsets.symmetric(horizontal: Ivy.s2),
              decoration: BoxDecoration(
                color: Ivy.surface.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(Ivy.rPill),
                // Filo claro arriba: es la luz dando en el canto del
                // material, lo que hace que se lea como una superficie y no
                // como un rectángulo semitransparente.
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                boxShadow: Ivy.floating,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < left.length; i++)
                    _NavIcon(
                      item: left[i],
                      active: index == i,
                      onTap: () => onSelect(i),
                    ),
                  _AddSlot(onTap: onAdd),
                  for (var i = 0; i < right.length; i++)
                    _NavIcon(
                      item: right[i],
                      active: index == half + i,
                      onTap: () => onSelect(half + i),
                    ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.88,
      onTap: onTap,
      child: Tooltip(
        message: item.label,
        child: SizedBox(
          width: IvyBottomNav._slot,
          height: IvyBottomNav._height,
          child: Center(
            // Sin etiqueta, la pestaña activa se marca con un punto debajo:
            // un relleno de color detrás del icono a este tamaño ensucia y
            // compite con el "+".
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  duration: IvyMotion.fast,
                  curve: IvyMotion.curve,
                  scale: active ? 1 : 0.94,
                  child: Icon(
                    active ? item.activeIcon : item.icon,
                    size: 22,
                    color: active ? Ivy.ink : Ivy.inkFaint,
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: IvyMotion.normal,
                  curve: IvyMotion.curve,
                  width: active ? 14 : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: Ivy.ink,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddSlot extends StatelessWidget {
  const _AddSlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Ivy.s2),
      child: Pressable(
        scale: 0.9,
        onTap: onTap,
        child: Tooltip(
          message: 'Añadir prenda',
          child: Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Ivy.ink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, color: Ivy.surface, size: 24),
          ),
        ),
      ),
    );
  }
}
