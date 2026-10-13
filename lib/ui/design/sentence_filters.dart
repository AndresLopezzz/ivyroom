import 'package:flutter/material.dart';

import 'components.dart';
import 'tokens.dart';
import 'type.dart';

/// Un hueco rellenable dentro de una frase de filtros.
///
/// Se llama `FilterSlot` y no `Slot` porque `Slot` ya es la ranura del
/// dominio (arriba, abajo, calzado) y esa es la que manda.
class FilterSlot {
  const FilterSlot({
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.icon,
  });

  /// Lo elegido, o null si el hueco sigue vacío.
  final String? value;

  /// Qué se pediría si estuviera vacío: "cualquier ocasión".
  final String placeholder;

  final VoidCallback onTap;
  final IconData? icon;
}

/// Filtros escritos como una frase.
///
/// En vez de una fila de chips iguales sin relación entre sí, los criterios
/// se leen de corrido: *outfits para **trabajo**, mood **elegante**, a
/// **18°***. La ventaja no es estética: una lista de chips no dice qué
/// significa cada uno ni cómo se combinan, y una frase sí. Los huecos vacíos
/// se ven distintos de los rellenos, así que se sabe de un vistazo qué está
/// filtrando de verdad.
class SentenceFilters extends StatelessWidget {
  const SentenceFilters({
    super.key,
    required this.parts,
    this.padding =
        const EdgeInsets.symmetric(horizontal: Ivy.gutter, vertical: Ivy.s2),
  });

  /// Trozos de la frase: `String` para el texto fijo, [FilterSlot] para los
  /// huecos rellenables.
  final List<Object> parts;

  final EdgeInsetsGeometry padding;

  /// Alto fijo de la franja. Se expone porque la pantalla que la coloca
  /// necesita reservar ese hueco exacto.
  static const height = 40.0;

  @override
  Widget build(BuildContext context) {
    // Una sola linea que se desplaza, y no un `Wrap` que crece: al envolver,
    // la frase pasaba de una a tres lineas segun lo que hubiera elegido y
    // empujaba el contenido de abajo cada vez. Alto fijo, lectura de
    // izquierda a derecha.
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding.resolve(TextDirection.ltr),
        itemCount: parts.length,
        separatorBuilder: (_, _) => const SizedBox(width: Ivy.s2),
        itemBuilder: (_, i) {
          final part = parts[i];
          if (part is String) {
            return Center(
              child: Text(part,
                  style: IvyType.body.copyWith(color: Ivy.inkFaint)),
            );
          }
          final slot = part as FilterSlot;
          return Center(
            child: Pill(
              label: slot.value ?? slot.placeholder,
              icon: slot.icon,
              selected: slot.value != null,
              tone: PillTone.onSurface,
              onTap: slot.onTap,
              dense: true,
            ),
          );
        },
      ),
    );
  }
}
