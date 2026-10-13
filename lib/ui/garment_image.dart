import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/models/garment.dart';

/// Pinta la imagen de una prenda a partir de su ruta RELATIVA.
///
/// La resolucion a ruta absoluta pasa siempre por `ImageStorage`, nunca se
/// concatena a mano: es lo que hace que las imagenes sobrevivan a una
/// reinstalacion, donde la raiz del sandbox cambia.
class GarmentImage extends ConsumerWidget {
  const GarmentImage({
    super.key,
    required this.garment,
    this.useThumb = true,
    this.fit = BoxFit.contain,
  });

  final Garment garment;

  /// El grid usa siempre la miniatura: cargar el PNG completo en cada celda
  /// es lo que rompe el scroll con cien prendas.
  final bool useThumb;

  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(imageStorageProvider).value;
    if (storage == null) {
      return const Center(child: SizedBox.shrink());
    }

    final rel = useThumb ? garment.thumbPath : garment.imagePath;
    final file = storage.fileFor(rel);

    // Se decodifica al tamano en que se va a pintar, no al del fichero. Sin
    // esto cada imagen ocupa en RAM su resolucion completa (un recorte de
    // 1600 px son ~10 MB descomprimido) aunque se vea en una celda de 120.
    return LayoutBuilder(builder: (context, constraints) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      int? px(double v) => v.isFinite ? (v * dpr).ceil() : null;
      final w = px(constraints.maxWidth);
      return _image(context, file, cacheWidth: w,
          cacheHeight: w == null ? px(constraints.maxHeight) : null);
    });
  }

  Widget _image(
    BuildContext context,
    File file, {
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.file(
      file,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      // La imagen puede haber desaparecido (limpieza del sistema, backup
      // restaurado a medias); una celda rota no debe tumbar la rejilla.
      errorBuilder: (context, _, _) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, size: 32),
        ),
      ),
    );
  }
}

/// Circulo con el color dominante de la prenda.
class ColorDot extends StatelessWidget {
  const ColorDot(this.argb, {super.key, this.size = 14});

  final int argb;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(argb),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

/// Fondo a cuadros. Sin el, un PNG con fondo transparente sobre un tema
/// claro parece que no se ha recortado.
class CheckerboardBackground extends StatelessWidget {
  const CheckerboardBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerPainter(Theme.of(context).colorScheme),
      child: child,
    );
  }
}

class _CheckerPainter extends CustomPainter {
  _CheckerPainter(this.scheme);

  final ColorScheme scheme;
  static const _cell = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final a = Paint()..color = scheme.surfaceContainerLow;
    final b = Paint()..color = scheme.surfaceContainerHighest;
    canvas.drawRect(Offset.zero & size, a);
    for (var y = 0; y < size.height / _cell; y++) {
      for (var x = 0; x < size.width / _cell; x++) {
        if ((x + y).isEven) continue;
        canvas.drawRect(
          Rect.fromLTWH(x * _cell, y * _cell, _cell, _cell),
          b,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter old) => old.scheme != scheme;
}
