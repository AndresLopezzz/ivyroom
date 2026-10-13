import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../ui/garment_image.dart';

/// Un trazo de brocha, en coordenadas de la imagen original (no de pantalla),
/// para que el resultado no dependa del tamano del movil ni del zoom.
class _Stroke {
  _Stroke({required this.erase, required this.radius})
      : points = <Offset>[];

  final bool erase;
  final double radius;
  final List<Offset> points;

  Path get path {
    final p = Path();
    if (points.isEmpty) return p;
    p.moveTo(points.first.dx, points.first.dy);
    for (final pt in points.skip(1)) {
      p.lineTo(pt.dx, pt.dy);
    }
    return p;
  }
}

/// Editor de mascara: borrar y restaurar zonas de la prenda a mano.
///
/// No hay ningun paquete que pinte sobre el canal alfa de una foto, asi que
/// se implementa a mano. La idea es simple: los trazos NO se aplican a los
/// pixeles mientras se dibuja. Se acumulan en una lista, se pintan como una
/// mascara en una capa aparte, y esa mascara se compone sobre la imagen con
/// [BlendMode.dstIn]. Solo al confirmar se rasteriza. Por eso deshacer es
/// quitar el ultimo elemento de una lista, y no hay que guardar copias del
/// bitmap.
class MaskEditor extends StatefulWidget {
  const MaskEditor({
    super.key,
    required this.image,
    required this.onDone,
    this.source,
    this.title = 'Retocar recorte',
  });

  /// PNG de partida. Puede venir ya recortado por ML Kit o ser la foto
  /// original sin tocar, en el modo manual.
  final Uint8List image;

  /// Foto sin recortar del mismo tamano que [image]. Si llega, "Restaurar"
  /// devuelve sus pixeles: es lo que permite recuperar lo que ML Kit quito
  /// de mas. Sin ella, restaurar solo deshace lo borrado en esta sesion.
  final Uint8List? source;

  /// Devuelve el PNG final con el alfa ya aplicado, o null si se cancela.
  final void Function(Uint8List? result) onDone;

  final String title;

  @override
  State<MaskEditor> createState() => _MaskEditorState();
}

class _MaskEditorState extends State<MaskEditor> {
  ui.Image? _image;

  /// De donde salen los pixeles. Es [_image] si no hay foto original.
  ui.Image? _source;
  final _strokes = <_Stroke>[];
  final _redo = <_Stroke>[];
  _Stroke? _current;

  bool _erasing = true;
  double _brush = 40;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void dispose() {
    if (_source != _image) _source?.dispose();
    _image?.dispose();
    super.dispose();
  }

  Future<void> _decode() async {
    final image = await _decodeBytes(widget.image);
    final src = widget.source;
    var source = src == null ? null : await _decodeBytes(src);
    // Si no encajan, restaurar desde ella pintaria la prenda desplazada.
    // Mejor perder esa capacidad que estropear el recorte.
    if (source != null &&
        (source.width != image.width || source.height != image.height)) {
      source.dispose();
      source = null;
    }
    if (!mounted) {
      image.dispose();
      source?.dispose();
      return;
    }
    setState(() {
      _image = image;
      _source = source ?? image;
    });
  }

  static Future<ui.Image> _decodeBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    return (await codec.getNextFrame()).image;
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => widget.onDone(null),
        ),
        actions: [
          IconButton(
            tooltip: 'Deshacer',
            icon: const Icon(Icons.undo),
            onPressed: _strokes.isEmpty ? null : _undo,
          ),
          IconButton(
            tooltip: 'Rehacer',
            icon: const Icon(Icons.redo),
            onPressed: _redo.isEmpty ? null : _redoLast,
          ),
          TextButton(
            onPressed: _exporting || image == null ? null : _confirm,
            child: const Text('Listo'),
          ),
        ],
      ),
      body: image == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: _canvas(image)),
                _toolbar(context),
              ],
            ),
    );
  }

  // ---- lienzo con zoom ----------------------------------------------------
  //
  // Un dedo pinta; dos dedos acercan y mueven. Va a mano y no con
  // `InteractiveViewer` porque ahi el gesto de dibujar se comia el de
  // pellizcar y el zoom no llegaba a funcionar.

  double _zoom = 1;
  Offset _pan = Offset.zero;
  bool _pinching = false;
  double _zoomAtStart = 1;
  Offset _panAtStart = Offset.zero;
  Offset _focalAtStart = Offset.zero;

  Widget _canvas(ui.Image image) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // La imagen se ajusta por contain dentro del area disponible.
        final scale = (constraints.maxWidth / image.width)
            .clamp(0.0, constraints.maxHeight / image.height);
        final displaySize = Size(image.width * scale, image.height * scale);
        final base = Offset(
          (constraints.maxWidth - displaySize.width) / 2,
          (constraints.maxHeight - displaySize.height) / 2,
        );

        // Punto de pantalla -> pixel de la imagen original.
        Offset toImage(Offset screen) =>
            ((screen - _pan) / _zoom - base) / scale;

        return ClipRect(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: (d) {
              if (d.pointerCount >= 2) {
                _beginPinch(d.localFocalPoint);
              } else {
                _startStroke(toImage(d.localFocalPoint));
              }
            },
            onScaleUpdate: (d) {
              if (d.pointerCount >= 2) {
                // Si el segundo dedo llega despues, el trazo que empezo con
                // el primero no era un trazo: era el comienzo del pellizco.
                if (!_pinching) {
                  setState(() => _current = null);
                  _beginPinch(d.localFocalPoint);
                }
                final zoom = (_zoomAtStart * d.scale).clamp(1.0, 8.0);
                // El punto bajo los dedos se queda bajo los dedos.
                final anchor = (_focalAtStart - _panAtStart) / _zoomAtStart;
                setState(() {
                  _zoom = zoom;
                  _pan = d.localFocalPoint - anchor * zoom;
                });
              } else if (!_pinching) {
                _extendStroke(toImage(d.localFocalPoint));
              }
            },
            onScaleEnd: (_) {
              if (_pinching) {
                _pinching = false;
              } else {
                _endStroke();
              }
            },
            child: Transform(
              transform: Matrix4.identity()
                ..translateByDouble(_pan.dx, _pan.dy, 0, 1)
                ..scaleByDouble(_zoom, _zoom, 1, 1),
              child: Stack(
                children: [
                  Positioned(
                    left: base.dx,
                    top: base.dy,
                    width: displaySize.width,
                    height: displaySize.height,
                    child: CheckerboardBackground(
                      child: CustomPaint(
                        painter: _MaskPainter(
                          image: image,
                          source: _source!,
                          strokes: [..._strokes, ?_current],
                          scale: scale,
                        ),
                        size: displaySize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _beginPinch(Offset focal) {
    _pinching = true;
    _zoomAtStart = _zoom;
    _panAtStart = _pan;
    _focalAtStart = focal;
  }

  void _resetZoom() => setState(() {
        _zoom = 1;
        _pan = Offset.zero;
      });

  Widget _toolbar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.cleaning_services_outlined),
                  label: Text('Borrar'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.brush_outlined),
                  label: Text('Restaurar'),
                ),
              ],
              selected: {_erasing},
              onSelectionChanged: (s) => setState(() => _erasing = s.first),
            ),
            Row(
              children: [
                const Icon(Icons.circle, size: 10),
                Expanded(
                  child: Slider(
                    value: _brush,
                    min: 8,
                    max: 160,
                    onChanged: (v) => setState(() => _brush = v),
                  ),
                ),
                const Icon(Icons.circle, size: 24),
                IconButton(
                  tooltip: 'Ver entera',
                  onPressed: _zoom == 1 ? null : _resetZoom,
                  icon: const Icon(Icons.zoom_out_map),
                ),
              ],
            ),
            Text(
              'Un dedo pinta · dos dedos acercan y mueven',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  // ---- trazos ------------------------------------------------------------

  void _startStroke(Offset imagePoint) {
    setState(() {
      // Empezar a dibujar invalida la pila de rehacer, igual que en
      // cualquier editor.
      _redo.clear();
      // El grosor es el que se ve en pantalla: con zoom, el pincel se
      // estrecha en la imagen, que es justo lo que da precision.
      _current = _Stroke(erase: _erasing, radius: _brush / _zoom)
        ..points.add(imagePoint);
    });
  }

  void _extendStroke(Offset imagePoint) {
    if (_current == null) return;
    setState(() => _current!.points.add(imagePoint));
  }

  void _endStroke() {
    final s = _current;
    if (s == null) return;
    setState(() {
      _strokes.add(s);
      _current = null;
    });
  }

  void _undo() => setState(() => _redo.add(_strokes.removeLast()));

  void _redoLast() => setState(() => _strokes.add(_redo.removeLast()));

  // ---- exportar ----------------------------------------------------------

  Future<void> _confirm() async {
    final image = _image!;
    if (_strokes.isEmpty) {
      // Sin retoques no hay nada que rasterizar: se devuelve el PNG original
      // tal cual y se ahorra un ciclo de codificacion.
      widget.onDone(widget.image);
      return;
    }

    setState(() => _exporting = true);
    try {
      final bytes = await _rasterize(image);
      widget.onDone(bytes);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// Pinta imagen + mascara a resolucion completa y devuelve el PNG.
  Future<Uint8List> _rasterize(ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(image.width.toDouble(), image.height.toDouble());

    _MaskPainter(
      image: image,
      source: _source!,
      strokes: _strokes,
      scale: 1,
    ).paint(canvas, size);

    final picture = recorder.endRecording();
    final rendered = await picture.toImage(image.width, image.height);
    picture.dispose();

    final data =
        await rendered.toByteData(format: ui.ImageByteFormat.png);
    rendered.dispose();

    // Si la codificacion falla se devuelve el original: mejor perder los
    // retoques que perder la foto.
    return data?.buffer.asUint8List() ?? widget.image;
  }
}

/// Pinta la imagen con la mascara aplicada.
///
/// Se usa tanto para la vista previa (con `scale` de pantalla) como para el
/// export final (con `scale` 1, a resolucion completa). Compartir el mismo
/// painter es lo que garantiza que lo que el usuario ve sea exactamente lo
/// que se guarda.
class _MaskPainter extends CustomPainter {
  _MaskPainter({
    required this.image,
    required this.source,
    required this.strokes,
    required this.scale,
  });

  /// Recorte de partida. Solo se usa su alfa, como mascara inicial.
  final ui.Image image;

  /// De donde salen los colores: la foto original si la hay.
  final ui.Image source;

  final List<_Stroke> strokes;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final dst = Offset.zero & size;

    final srcRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final quality = Paint()..filterQuality = FilterQuality.medium;

    canvas.saveLayer(dst, Paint());
    canvas.drawImageRect(source, srcRect, dst, quality);

    // Capa de mascara: arranca con el alfa del recorte (lo que ML Kit dejo),
    // los trazos de borrado abren agujeros y los de restaurar los tapan. Al
    // cerrar la capa con dstIn, esa mascara recorta la foto original.
    canvas.saveLayer(dst, Paint()..blendMode = BlendMode.dstIn);
    canvas.drawImageRect(image, srcRect, dst, quality);

    for (final stroke in strokes) {
      final paint = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..strokeWidth = stroke.radius * 2 * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        // `clear` abre el agujero; `src` lo tapa. Como debajo esta la foto
        // original, restaurar recupera tambien lo que ML Kit quito.
        ..blendMode = stroke.erase ? BlendMode.clear : BlendMode.src;

      final scaled = Path();
      final pts = stroke.points;
      if (pts.isEmpty) continue;
      if (pts.length == 1) {
        // Un toque suelto es un punto, no una linea: sin esto no pintaria
        // nada.
        canvas.drawCircle(
          pts.first * scale,
          stroke.radius * scale,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }
      scaled.moveTo(pts.first.dx * scale, pts.first.dy * scale);
      for (final p in pts.skip(1)) {
        scaled.lineTo(p.dx * scale, p.dy * scale);
      }
      canvas.drawPath(scaled, paint);
    }

    canvas.restore(); // aplica la mascara
    canvas.restore(); // vuelca el resultado
  }

  @override
  bool shouldRepaint(_MaskPainter old) =>
      old.image != image ||
      old.source != source ||
      old.scale != scale ||
      old.strokes.length != strokes.length ||
      (strokes.isNotEmpty &&
          old.strokes.isNotEmpty &&
          old.strokes.last.points.length != strokes.last.points.length);
}
