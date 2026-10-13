import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// La escala tipográfica.
///
/// Dos familias con papeles distintos:
///
/// - **Bricolage Grotesque** para los momentos con voz: el día de hoy, los
///   números grandes, los titulares. Es una grotesca variable con carácter
///   propio, que es justo lo que separa una interfaz con identidad de una
///   que usa la fuente por defecto del sistema.
/// - **Inter** para todo lo funcional: etiquetas, listas, formularios.
///   Neutra y legible a tamaño pequeño, con cifras tabulares.
///
/// El tracking es **específico del tamaño**, nunca uno solo para todo: al
/// crecer, las letras se leen demasiado separadas y hay que apretarlas; a
/// tamaño pequeño pasa lo contrario. Un `letterSpacing` fijo está mal en
/// algún sitio por definición.
class IvyType {
  const IvyType._();

  static TextStyle _display(double size, {double? tracking, FontWeight? w}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        fontWeight: w ?? FontWeight.w700,
        // Interlineado apretado en grande, holgado en pequeño.
        height: size >= 40 ? 0.95 : 1.05,
        letterSpacing: tracking ?? (size >= 40 ? -size * 0.035 : -size * 0.02),
        color: Ivy.ink,
      );

  static TextStyle _ui(
    double size, {
    FontWeight w = FontWeight.w500,
    double? tracking,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: w,
        height: height ?? (size <= 13 ? 1.35 : 1.45),
        // Las etiquetas pequeñas piden un pelo de aire entre letras.
        letterSpacing: tracking ?? (size <= 13 ? 0.1 : 0),
        color: color ?? Ivy.ink,
      );

  // ---- display -----------------------------------------------------------

  /// El número o la palabra que domina una pantalla. Se usa en minúscula.
  static TextStyle get hero => _display(52);

  /// Titular de pantalla: el día de hoy, el nombre de una sección grande.
  static TextStyle get display => _display(34);

  /// Titular de bloque.
  static TextStyle get title => _display(22);

  /// Cifra grande dentro de una tarjeta.
  static TextStyle get numeral =>
      _display(30, tracking: -1).copyWith(fontFeatures: const [
        FontFeature.tabularFigures(),
      ]);

  // ---- interfaz ----------------------------------------------------------

  static TextStyle get heading => _ui(17, w: FontWeight.w600);
  static TextStyle get body => _ui(15, w: FontWeight.w400);
  static TextStyle get bodyStrong => _ui(15, w: FontWeight.w600);
  static TextStyle get small => _ui(13, w: FontWeight.w400, color: Ivy.inkSoft);
  static TextStyle get smallStrong => _ui(13, w: FontWeight.w600);

  /// Etiqueta de sección.
  ///
  /// En minúscula y con la voz del display, no en mayúsculas con el tracking
  /// abierto: ese recurso está tan repetido en interfaces generadas que ya
  /// solo dice "esto lo hizo una máquina". La personalidad la pone la letra,
  /// no el bloque de mayúsculas.
  static TextStyle get label => GoogleFonts.bricolageGrotesque(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
        color: Ivy.inkSoft,
      );

  /// Variante tenue de [label], para rótulos secundarios.
  static TextStyle get labelFaint => label.copyWith(color: Ivy.inkFaint);

  /// Texto de un botón o de una píldora.
  static TextStyle get action => _ui(15, w: FontWeight.w600, tracking: -0.1);

  static TextStyle get caption =>
      _ui(12, w: FontWeight.w400, color: Ivy.inkFaint);
}
