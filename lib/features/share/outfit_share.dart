import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../domain/models/catalog.dart';
import '../../domain/models/garment.dart';
import '../../ui/design/tokens.dart';

/// Comparte un outfit como una imagen lista para WhatsApp o historias.
///
/// Se dibuja directamente en un `Canvas` y no capturando un widget: asi no
/// depende de lo que haya en pantalla ni de su tamano, y el resultado es
/// siempre el mismo lienzo 4:5, que es el formato que mejor recortan las
/// redes.
Future<void> shareOutfit(
  BuildContext context,
  WidgetRef ref,
  List<Garment> items, {
  String? title,
}) async {
  if (items.isEmpty) return;
  final storage = await ref.read(imageStorageProvider.future);
  if (!context.mounted) return;
  await shareCollage(context, [
    for (final g in items)
      if (storage.fileFor(g.imagePath).existsSync())
        (
          slot: g.slot,
          load: () => storage.fileFor(g.imagePath).readAsBytes(),
        ),
  ], title: title);
}

/// Una pieza del collage: en que ranura va y como conseguir su imagen.
typedef CollagePiece = ({Slot slot, Future<Uint8List> Function() load});

/// Comparte un collage de piezas cualesquiera: del armario propio o de uno
/// compartido, que llegan por red.
Future<void> shareCollage(
  BuildContext context,
  List<CollagePiece> pieces, {
  String? title,
}) async {
  if (pieces.isEmpty) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final png = await renderCollage(pieces, title: title);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/ivyroom_outfit_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(png, flush: true);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
    ));
  } catch (e) {
    messenger.showSnackBar(
        SnackBar(content: Text('No se pudo crear la imagen: $e')));
  }
}

const _w = 1080.0;
const _h = 1350.0;
const _pad = 64.0;

/// Orden de lectura de un outfit: de arriba abajo, como se lleva puesto.
const _order = [
  Slot.outer,
  Slot.top,
  Slot.dress,
  Slot.bottom,
  Slot.shoes,
  Slot.accessory,
];

Future<List<int>> renderCollage(
  List<CollagePiece> pieces, {
  String? title,
}) async {
  final sorted = [...pieces]
    ..sort((a, b) => _order.indexOf(a.slot).compareTo(_order.indexOf(b.slot)));

  final images = <(CollagePiece, ui.Image)>[];
  for (final piece in sorted) {
    try {
      // Se decodifica ya reducido: a 700 px de ancho sobra para una celda
      // del lienzo, y una prenda a resolucion completa son decenas de MB.
      final codec =
          await ui.instantiateImageCodec(await piece.load(), targetWidth: 700);
      images.add((piece, (await codec.getNextFrame()).image));
    } catch (_) {
      // Una imagen que no carga no tumba el collage entero.
    }
  }

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
      const Rect.fromLTWH(0, 0, _w, _h), Paint()..color = Ivy.paper);

  // Dos columnas: lo que forma la silueta (arriba, abajo, vestido) a la
  // izquierda y en grande; lo que la acompana (abrigo, zapatos, accesorios)
  // a la derecha. Con dos prendas o menos, una sola columna.
  const area = Rect.fromLTRB(_pad, _pad + 40, _w - _pad, _h - _pad - 90);
  final main = [
    for (final e in images)
      if (const {Slot.top, Slot.bottom, Slot.dress}.contains(e.$1.slot)) e,
  ];
  final side = [
    for (final e in images)
      if (!main.contains(e)) e,
  ];

  if (main.isEmpty || side.isEmpty || images.length <= 2) {
    _column(canvas, images.map((e) => e.$2).toList(), area);
  } else {
    final split = area.left + area.width * 0.6;
    _column(canvas, main.map((e) => e.$2).toList(),
        Rect.fromLTRB(area.left, area.top, split - 16, area.bottom));
    _column(canvas, side.map((e) => e.$2).toList(),
        Rect.fromLTRB(split + 16, area.top, area.right, area.bottom));
  }

  _text(canvas, 'ivyroom', const Offset(_pad, _pad - 8),
      size: 30, color: Ivy.inkFaint, spacing: 2);
  if (title != null && title.trim().isNotEmpty) {
    _text(canvas, title.trim(), const Offset(_pad, _h - _pad - 56),
        size: 44, color: Ivy.ink, weight: FontWeight.w600);
  }

  final picture = recorder.endRecording();
  final rendered = await picture.toImage(_w.toInt(), _h.toInt());
  picture.dispose();
  for (final e in images) {
    e.$2.dispose();
  }
  final data = await rendered.toByteData(format: ui.ImageByteFormat.png);
  rendered.dispose();
  return data!.buffer.asUint8List();
}

/// Reparte el alto de [box] entre las imagenes, en proporcion a su alto
/// natural, y pinta cada una centrada y entera.
void _column(Canvas canvas, List<ui.Image> images, Rect box) {
  if (images.isEmpty) return;
  const gap = 24.0;
  final available = box.height - gap * (images.length - 1);
  final weights = [
    for (final i in images) (i.height / i.width).clamp(0.5, 1.6),
  ];
  final total = weights.fold<double>(0, (a, b) => a + b);

  var y = box.top;
  for (final (k, img) in images.indexed) {
    final cell = Rect.fromLTWH(box.left, y, box.width, available * weights[k] / total);
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    final fitted = applyBoxFit(BoxFit.contain, src.size, cell.size);
    final dst = Alignment.center.inscribe(fitted.destination, cell);
    canvas.drawImageRect(
        img, src, dst, Paint()..filterQuality = FilterQuality.medium);
    y = cell.bottom + gap;
  }
}

void _text(
  Canvas canvas,
  String text,
  Offset at, {
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w400,
  double spacing = 0,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: spacing,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: _w - _pad * 2);
  tp.paint(canvas, at);
}
