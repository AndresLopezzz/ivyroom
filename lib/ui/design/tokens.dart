import 'package:flutter/material.dart';

/// Los valores base del diseño. Nada de esto se elige dos veces en el resto
/// de la app: si un número aparece suelto en una pantalla, es un error.
///
/// La decisión de fondo es que **la interfaz es acromática**. En una app de
/// armario el color lo ponen las prendas; una UI con su propia paleta
/// competiría con las fotos y volvería el catálogo ilegible. Solo hay tinta,
/// papel y un verde muy contenido para las confirmaciones.
class Ivy {
  const Ivy._();

  // ---- color -------------------------------------------------------------

  /// Papel. Cálido, no gris frío: un gris azulado con esquinas redondeadas
  /// es la firma visual de las plantillas genéricas.
  static const paper = Color(0xFFF6F5F2);

  /// Las tarjetas son blanco puro sobre el papel. La elevación se lee por
  /// **valor**, no por sombra: por eso casi no hay sombras en toda la app.
  static const surface = Color(0xFFFFFFFF);

  /// Tinta. Negro cálido, nunca #000: el negro puro sobre papel cálido
  /// vibra.
  static const ink = Color(0xFF141310);
  static const inkSoft = Color(0xFF56534C);
  static const inkFaint = Color(0xFF8E8A81);

  /// Línea de un pelo. Se usa muy poco: separar por espacio es mejor que
  /// separar por línea.
  static const hairline = Color(0xFFE7E4DD);

  /// El único acento cromático, y solo para "hecho": lo puesto, lo lavado,
  /// lo confirmado.
  static const sage = Color(0xFF4F6B4A);
  static const sageSoft = Color(0xFFE8EDE6);

  /// Avisos. Terracota en vez de rojo señal, que sobre papel cálido chirría.
  static const clay = Color(0xFFA6512F);
  static const claySoft = Color(0xFFF6E8E1);

  // ---- espacio -----------------------------------------------------------

  /// Escala de 4. Los saltos son grandes a propósito: el ritmo se nota
  /// cuando hay pocos valores y muy distintos.
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 24.0;
  static const s6 = 32.0;
  static const s7 = 48.0;
  static const s8 = 64.0;

  /// Margen lateral de las pantallas.
  static const gutter = 20.0;

  // ---- radios ------------------------------------------------------------

  /// El radio depende del tamaño del objeto. Redondear todo a 16 sin mirar
  /// el tamaño es el tic más reconocible de una interfaz generada.
  static const rThumb = 10.0;
  static const rCard = 20.0;
  static const rSheet = 28.0;
  static const rPill = 999.0;

  // ---- sombras -----------------------------------------------------------

  /// Reservada para lo que de verdad flota sobre el contenido: la barra
  /// inferior y poco más.
  static const floating = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  /// Elevación mínima para tarjetas que se levantan del papel al tocarlas.
  static const lifted = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
