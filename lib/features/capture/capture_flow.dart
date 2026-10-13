import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../data/images/background_remover.dart';
import '../../data/intake/garment_intake.dart';
import '../../ui/garment_image.dart';
import 'mask_editor.dart';
import 'tag_form.dart';

/// Pasos del alta de una prenda.
enum _Step { source, crop, mode, mask, tag }

/// El alta de prenda, paso a paso.
///
/// Esta pantalla ya no sabe nada de isolates, ficheros temporales, ML Kit ni
/// drift: todo eso vive en [GarmentIntake]. Aquí solo queda qué paso enseñar
/// y qué error pintar, que es lo único que le corresponde a un widget.
class CaptureFlowScreen extends ConsumerStatefulWidget {
  const CaptureFlowScreen({super.key});

  @override
  ConsumerState<CaptureFlowScreen> createState() => _CaptureFlowScreenState();
}

class _CaptureFlowScreenState extends ConsumerState<CaptureFlowScreen> {
  final _picker = ImagePicker();
  final _cropController = CropController();

  _Step _step = _Step.source;

  Uint8List? _photo;
  Uint8List? _framed;
  GarmentCutout? _cutout;

  bool _busy = false;
  String? _busyLabel;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Android puede matar la Activity mientras la cámara está abierta; sin
    // esto la foto recién hecha se pierde en silencio.
    _recoverLostPhoto();
  }

  Future<void> _recoverLostPhoto() async {
    final lost = await _picker.retrieveLostData();
    final file = lost.file;
    if (lost.isEmpty || file == null || !mounted) return;
    await _loadPhoto(File(file.path));
  }

  Future<GarmentIntake> get _intake =>
      ref.read(garmentIntakeProvider.future);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == _Step.source,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(switch (_step) {
            _Step.source => 'Nueva prenda',
            _Step.crop => 'Encuadra la prenda',
            _Step.mode => 'Quitar el fondo',
            _Step.mask => 'Retocar',
            _Step.tag => 'Detalles',
          }),
          leading: IconButton(
            icon: Icon(_step == _Step.source ? Icons.close : Icons.arrow_back),
            onPressed: _back,
          ),
        ),
        body: Stack(
          children: [
            switch (_step) {
              _Step.source => _sourceStep(),
              _Step.crop => _cropStep(),
              _Step.mode => _modeStep(),
              _Step.mask => _maskStep(),
              _Step.tag => _tagStep(),
            },
            if (_busy) _busyOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _busyOverlay() => ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (_busyLabel != null) ...[
                const SizedBox(height: 16),
                Text(_busyLabel!,
                    style: const TextStyle(color: Colors.white)),
              ],
            ],
          ),
        ),
      );

  /// Corre una operación del alta enseñando el indicador y capturando el
  /// error en un solo sitio, en vez de repetir el mismo try/finally con
  /// guardas de `mounted` en cada paso.
  Future<T?> _run<T>(String label, Future<T> Function() action) async {
    setState(() {
      _busy = true;
      _busyLabel = label;
      _error = null;
    });
    try {
      return await action();
    } on BackgroundRemovalException catch (e) {
      if (mounted) setState(() => _error = e.messageWithDetail);
      return null;
    } catch (e) {
      if (mounted) setState(() => _error = 'Algo salió mal: $e');
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---- paso 1: origen ----------------------------------------------------

  Widget _sourceStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checkroom, size: 72),
            const SizedBox(height: 8),
            Text(
              'Pon la prenda sobre un fondo liso y con buena luz. El recorte '
              'automático acierta mucho más así.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _pick(ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Tomar una foto'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Elegir de la galería'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              // Reemplaza esta pantalla: volver desde la tanda no debe caer
              // otra vez aqui.
              onPressed: () => context.pushReplacement('/capture-batch'),
              icon: const Icon(Icons.collections_outlined),
              label: const Text('Añadir varias a la vez'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              _ErrorBanner(message: _error!),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await _run('Abriendo...', () async {
      return _picker.pickImage(
        source: source,
        // Se limita ya en el picker: 12 Mpx no mejoran ni el recorte ni el
        // color, y multiplican memoria y tiempo.
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 92,
      );
    });
    if (picked == null) return;
    final file = File(picked.path);
    try {
      await _loadPhoto(file);
    } finally {
      // En Android el picker deja una copia en la caché por cada foto y no la
      // borra nunca. Ya está leída a memoria: aquí no sirve para nada.
      try {
        if (file.existsSync()) await file.delete();
      } on FileSystemException {
        // Un temporal que no se puede borrar no debe romper el alta.
      }
    }
  }

  Future<void> _loadPhoto(File file) async {
    final normalized = await _run('Cargando foto...', () async {
      final intake = await _intake;
      return intake.normalizePhoto(await file.readAsBytes());
    });
    if (normalized == null || !mounted) return;
    setState(() {
      _photo = normalized;
      _step = _Step.crop;
    });
  }

  // ---- paso 2: encuadre --------------------------------------------------

  Widget _cropStep() {
    return Column(
      children: [
        Expanded(
          child: Crop(
            image: _photo!,
            controller: _cropController,
            baseColor: Theme.of(context).colorScheme.surface,
            maskColor: Colors.black.withValues(alpha: 0.55),
            // Pellizcar acerca la foto bajo el recuadro: con la prenda lejos
            // en la foto, sin zoom el recuadro no se puede ajustar bien.
            interactive: true,
            cornerDotBuilder: (size, edge) => Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 3),
                ),
              ),
            ),
            onCropped: (result) => switch (result) {
              CropSuccess(:final croppedImage) => _onCropped(croppedImage),
              CropFailure(:final cause) =>
                setState(() => _error = 'No se pudo recortar: $cause'),
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                TextButton(
                  // Saltarse el encuadre es legítimo: si la foto ya está
                  // bien, obligar a recortar solo estorba.
                  onPressed: () => _onCropped(_photo!),
                  child: const Text('Usar entera'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _cropController.crop,
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onCropped(Uint8List bytes) => setState(() {
        _framed = bytes;
        _step = _Step.mode;
      });

  // ---- paso 3: modo de recorte -------------------------------------------

  Widget _modeStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 240,
          child: CheckerboardBackground(
            child: Image.memory(_framed!, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 24),
        for (final mode in RemovalMode.values)
          Card(
            child: ListTile(
              title: Text(mode.label),
              subtitle: Text(mode.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _runRemoval(mode),
            ),
          ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          _ErrorBanner(message: _error!),
          const SizedBox(height: 12),
          // Un fallo del recorte automático no debería obligar a repetir la
          // foto: se ofrece seguir a mano con lo que ya hay.
          FilledButton.tonalIcon(
            onPressed: () => _runRemoval(RemovalMode.manual),
            icon: const Icon(Icons.brush_outlined),
            label: const Text('Recortar a mano'),
          ),
        ],
      ],
    );
  }

  Future<void> _runRemoval(RemovalMode mode) async {
    final cutout = await _run('Recortando la prenda...', () async {
      final intake = await _intake;
      return intake.prepare(_framed!, mode);
    });
    if (cutout == null || !mounted) return;

    setState(() {
      _cutout = cutout;
      _step = cutout.needsTouchUp ? _Step.mask : _Step.tag;
    });
  }

  // ---- paso 4: retoque manual --------------------------------------------

  Widget _maskStep() {
    return MaskEditor(
      image: _cutout!.png,
      source: _cutout!.source,
      onDone: (result) async {
        if (result == null) {
          setState(() => _step = _Step.mode);
          return;
        }
        final done = await _run('Analizando el color...', () async {
          final intake = await _intake;
          return intake.finishTouchUp(_cutout!, result);
        });
        if (done == null || !mounted) return;
        setState(() {
          _cutout = done;
          _step = _Step.tag;
        });
      },
    );
  }

  // ---- paso 5: etiquetado ------------------------------------------------

  Widget _tagStep() {
    return TagForm(
      image: _cutout!.png,
      palette: _cutout!.palette,
      onSave: _save,
    );
  }

  Future<void> _save(GarmentTagging tagging) async {
    final id = await _run('Guardando...', () async {
      final intake = await _intake;
      return intake.commit(_cutout!, tagging);
    });
    if (id == null || !mounted) return;

    context.go('/closet');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prenda añadida al armario')),
    );
  }

  // ---- navegación --------------------------------------------------------

  void _back() {
    setState(() => _error = null);
    switch (_step) {
      case _Step.source:
        context.pop();
      case _Step.crop:
        setState(() => _step = _Step.source);
      case _Step.mode:
        setState(() => _step = _Step.crop);
      case _Step.mask:
      case _Step.tag:
        setState(() => _step = _Step.mode);
    }
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: TextStyle(color: scheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
