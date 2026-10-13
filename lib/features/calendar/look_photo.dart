import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../data/images/image_ops.dart';
import '../../data/repos/plan_repository.dart';

/// Pide una foto del look (camara o galeria) y la asocia al plan.
///
/// Es el diario: con el tiempo el calendario se convierte en un album de lo
/// que se llevo cada dia, que es lo que de verdad apetece volver a mirar.
Future<void> addLookPhoto(
  BuildContext context,
  WidgetRef ref,
  DayPlan plan,
) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tomar foto'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Elegir de la galería'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return;

  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 2000,
    maxHeight: 2000,
    imageQuality: 92,
  );
  if (picked == null) return;

  final file = File(picked.path);
  try {
    final png = await compute(downscaleLook, await file.readAsBytes());
    final storage = await ref.read(imageStorageProvider.future);
    final rel = await storage.writeLook(png);
    final previous =
        await ref.read(planRepositoryProvider).setPhoto(plan.id, rel);
    await storage.deleteAll([previous]);
  } finally {
    // Igual que en el alta: el picker deja una copia en la cache.
    try {
      if (file.existsSync()) await file.delete();
    } on FileSystemException {
      // No importa.
    }
  }
}

Future<void> removeLookPhoto(WidgetRef ref, DayPlan plan) async {
  final previous =
      await ref.read(planRepositoryProvider).setPhoto(plan.id, null);
  final storage = await ref.read(imageStorageProvider.future);
  await storage.deleteAll([previous]);
}

/// La foto a pantalla completa, con zoom.
class LookPhotoViewer extends ConsumerWidget {
  const LookPhotoViewer({super.key, required this.plan});

  final DayPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(imageStorageProvider).value;
    final path = plan.photoPath;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Cambiar foto',
            icon: const Icon(Icons.photo_camera_outlined),
            onPressed: () async {
              await addLookPhoto(context, ref, plan);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          IconButton(
            tooltip: 'Quitar foto',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await removeLookPhoto(ref, plan);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: storage == null || path == null
          ? const SizedBox.shrink()
          : InteractiveViewer(
              maxScale: 5,
              child: Center(child: Image.file(storage.fileFor(path))),
            ),
    );
  }
}
