import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../data/images/background_remover.dart';
import '../../data/intake/garment_intake.dart';
import 'mask_editor.dart';
import 'tag_form.dart';

/// Una foto de la tanda, en el estado en que va.
class _Item {
  _Item(this.id);

  final int id;
  Uint8List? photo;

  /// Recorte de ML Kit del tamano de la foto, con la foto como fuente: es lo
  /// que necesita el editor para poder restaurar. Se actualiza con cada
  /// edicion, para que reeditar parta de lo ya retocado.
  GarmentCutout? raw;

  /// Lo que se guarda: recortado al contorno y con su color.
  GarmentCutout? cutout;
  String? error;

  bool get ready => cutout != null;
  bool get failed => error != null;
}

/// Alta de muchas prendas de una sentada.
///
/// Con un armario grande, el flujo de una en una (foto, encuadre, recorte,
/// etiquetas) son cinco pantallas por prenda. Aqui se eligen todas las fotos
/// de golpe, el recorte automatico corre en segundo plano mientras tanto, y
/// solo queda ir etiquetando una tras otra. El tipo es lo unico obligatorio.
class BatchCaptureScreen extends ConsumerStatefulWidget {
  const BatchCaptureScreen({super.key});

  @override
  ConsumerState<BatchCaptureScreen> createState() => _BatchCaptureState();
}

class _BatchCaptureState extends ConsumerState<BatchCaptureScreen> {
  final _items = <_Item>[];
  var _saved = 0;
  var _picked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pick());
  }

  Future<void> _pick() async {
    final files = await ImagePicker().pickMultiImage(
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 92,
    );
    if (!mounted) return;
    if (files.isEmpty) {
      context.pop();
      return;
    }
    setState(() {
      _picked = true;
      for (var i = 0; i < files.length; i++) {
        _items.add(_Item(i));
      }
    });

    // De una en una y no en paralelo: ML Kit y la decodificacion de fotos de
    // varios megapixeles a la vez se comen la memoria del movil. Y en orden,
    // para que la primera este lista lo antes posible.
    final intake = await ref.read(garmentIntakeProvider.future);
    for (var i = 0; i < files.length; i++) {
      final file = File(files[i].path);
      final item = _items.firstWhere((e) => e.id == i, orElse: () => _Item(-1));
      if (item.id < 0) continue; // descartada mientras esperaba
      try {
        final photo = await intake.normalizePhoto(await file.readAsBytes());
        item.photo = photo;
        // Con retoque y no automatico: asi el recorte llega sin ajustar al
        // contorno y con la foto al lado, por si hay que editarlo.
        final raw = await intake.prepare(photo, RemovalMode.autoThenTouchUp);
        item.raw = raw;
        item.cutout = await intake.finishTouchUp(raw, raw.png);
      } on BackgroundRemovalException catch (e) {
        item.error = e.messageWithDetail;
      } catch (e) {
        item.error = 'No se pudo procesar: $e';
      } finally {
        try {
          if (file.existsSync()) await file.delete();
        } on FileSystemException {
          // La copia del picker en la cache; no importa.
        }
      }
      if (mounted) setState(() {});
    }
  }

  _Item? get _current => _items.isEmpty ? null : _items.first;

  Future<void> _save(_Item item, GarmentTagging tagging) async {
    final intake = await ref.read(garmentIntakeProvider.future);
    try {
      await intake.commit(item.cutout!, tagging);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo guardar: $e')));
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _items.remove(item);
      _saved++;
    });
    if (_items.isEmpty) _finish();
  }

  /// Sin recorte: se usa la foto entera. Mejor una prenda con fondo que
  /// perderla, y siempre se puede rehacer luego.
  Future<void> _useWhole(_Item item) async {
    final photo = item.photo;
    if (photo == null) return;
    final intake = await ref.read(garmentIntakeProvider.future);
    final manual = await intake.prepare(photo, RemovalMode.manual);
    final done = await intake.finishTouchUp(manual, photo);
    if (!mounted) return;
    setState(() {
      // Sin fuente: no hay recorte automatico que restaurar, pero si se
      // puede borrar el fondo a mano.
      item.raw = manual;
      item.cutout = done;
      item.error = null;
    });
  }

  /// Abre el editor de recorte sobre esta prenda. Opcional: solo para cuando
  /// el automatico se comio o dejo algo de mas.
  Future<void> _edit(_Item item) async {
    final raw = item.raw;
    if (raw == null) return;
    final edited = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MaskEditor(
          image: raw.png,
          source: raw.source,
          onDone: (result) => Navigator.pop(ctx, result),
        ),
      ),
    );
    if (edited == null || !mounted) return;
    final intake = await ref.read(garmentIntakeProvider.future);
    final done = await intake.finishTouchUp(raw, edited);
    if (!mounted) return;
    setState(() {
      item.raw = GarmentCutout(
        png: edited,
        palette: raw.palette,
        needsTouchUp: true,
        source: raw.source,
      );
      item.cutout = done;
    });
  }

  void _skip(_Item item) {
    setState(() => _items.remove(item));
    if (_items.isEmpty) _finish();
  }

  void _finish() {
    if (!mounted) return;
    context.go('/closet');
    if (_saved > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_saved == 1
            ? '1 prenda añadida al armario'
            : '$_saved prendas añadidas al armario'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _current;
    final pending = _items.where((e) => !e.ready && !e.failed).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _finish,
        ),
        title: Text(!_picked
            ? 'Varias prendas'
            : '${_saved + 1} de ${_saved + _items.length}'),
        actions: [
          if (pending > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text('$pending recortando…',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          if (item != null && (item.ready || item.failed))
            TextButton(
              onPressed: () => _skip(item),
              child: const Text('Saltar'),
            ),
        ],
      ),
      body: item == null
          ? const SizedBox.shrink()
          : item.failed
              ? _failed(item)
              : !item.ready
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Recortando la prenda…'),
                        ],
                      ),
                    )
                  : TagForm(
                      // Una clave por foto: sin ella el formulario
                      // conservaria lo escrito para la prenda anterior.
                      key: ValueKey(item.id),
                      image: item.cutout!.png,
                      palette: item.cutout!.palette,
                      onEditImage:
                          item.raw == null ? null : () => _edit(item),
                      saveLabel: _items.length == 1
                          ? 'Guardar y terminar'
                          : 'Guardar y siguiente',
                      onSave: (t) => _save(item, t),
                    ),
    );
  }

  Widget _failed(_Item item) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.photo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(item.photo!, height: 220, cacheHeight: 440),
              ),
            const SizedBox(height: 16),
            Text(item.error!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (item.photo != null)
              FilledButton.tonal(
                onPressed: () => _useWhole(item),
                child: const Text('Usar la foto entera'),
              ),
            TextButton(
              onPressed: () => _skip(item),
              child: const Text('Saltar esta'),
            ),
          ],
        ),
      ),
    );
  }
}
