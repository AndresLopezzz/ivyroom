import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/intake/garment_intake.dart';
import '../../data/repos/garment_repository.dart';
import '../../domain/color/color_extractor.dart';
import '../../domain/models/garment.dart';
import '../../ui/design/motion.dart';
import '../../ui/garment_image.dart';
import '../../ui/labels.dart';
import '../capture/tag_form.dart';

class GarmentDetailScreen extends ConsumerWidget {
  const GarmentDetailScreen({super.key, required this.garmentId});

  final int garmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Se lee del stream del armario y no con un findById puntual: así la
    // pantalla se actualiza sola tras editar, marcar favorita o archivar.
    final garment = ref
        .watch(fullWardrobeProvider)
        .value
        ?.where((g) => g.id == garmentId)
        .firstOrNull;

    if (garment == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(garment.displayName),
        actions: [
          IconButton(
            tooltip: garment.isFavorite ? 'Quitar favorita' : 'Favorita',
            icon: Icon(
              garment.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () => ref
                .read(garmentRepositoryProvider)
                .setFavorite(garment.id, !garment.isFavorite),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => _onMenu(context, ref, garment, v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(
                value: 'outfit',
                child: Text('Armar outfit con esta'),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Text(garment.isArchived ? 'Desarchivar' : 'Archivar'),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Borrar')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 300,
            child: GarmentImage(garment: garment, useThumb: false),
          ),
          const SizedBox(height: 24),
          _InfoRow(
            label: 'Tipo',
            value:
                '${garment.category.name}  ·  '
                '${Labels.slot(garment.slot)}',
          ),
          _InfoRow(
            label: 'Color',
            value: Labels.colorFamily(garment.colorFamily),
            trailing: ColorDot(garment.dominantColorArgb, size: 20),
          ),
          if (garment.brand != null)
            _InfoRow(label: 'Marca', value: garment.brand!),
          _InfoRow(label: 'Veces puesta', value: '${garment.wearCount}'),
          if (garment.washGroup != null)
            _InfoRow(label: 'Lava con', value: garment.washGroup!.name),
          _InfoRow(label: 'Lavadas', value: _washSummary(garment)),
          if (garment.lastWashedAt != null)
            _InfoRow(
              label: 'Última lavada',
              value: _formatDate(garment.lastWashedAt!),
            ),
          if (garment.lastWornAt != null)
            _InfoRow(
              label: 'Última vez',
              value: _formatDate(garment.lastWornAt!),
            ),
          if (garment.seasons.isNotEmpty)
            _ChipRow(
              label: 'Temporada',
              values: garment.seasons.map(Labels.season).toList(),
            ),
          if (garment.occasions.isNotEmpty)
            _ChipRow(
              label: 'Ocasión',
              values: garment.occasions.map((o) => o.name).toList(),
            ),
          if (garment.moods.isNotEmpty)
            _ChipRow(
              label: 'Mood',
              values: garment.moods.map((m) => m.name).toList(),
            ),
          if (garment.tags.isNotEmpty)
            _ChipRow(label: 'Tags', values: garment.tags.toList()),
          if (garment.notes != null) ...[
            const SizedBox(height: 16),
            Text(garment.notes!),
          ],
          if (garment.needsWashing) ...[
            const SizedBox(height: 16),
            _DirtyBanner(),
          ],
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () async {
              await ref.read(garmentRepositoryProvider).markWorn(garment.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marcada como puesta hoy')),
                );
              }
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('La usé hoy'),
          ),
        ],
      ),
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    Garment garment,
    String action,
  ) async {
    final repo = ref.read(garmentRepositoryProvider);

    switch (action) {
      case 'edit':
        await Navigator.of(context).push(
          IvyRoute<void>(builder: (_) => _EditGarmentScreen(garment: garment)),
        );

      case 'outfit':
        ref.read(outfitBuilderProvider.notifier)
          ..clear()
          ..toggle(garment);
        if (context.mounted) context.push('/build-outfit');

      case 'archive':
        await repo.setArchived(garment.id, !garment.isArchived);

      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Borrar prenda'),
            content: Text(
              '"${garment.displayName}" se borra del armario junto con su '
              'foto. Esto no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Borrar'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;

        // Primero la fila y después los ficheros: si el borrado de ficheros
        // falla quedan huérfanos, pero al revés quedaría una prenda en el
        // armario apuntando a una imagen que ya no existe.
        await repo.delete(garment.id);
        final storage = await ref.read(imageStorageProvider.future);
        await storage.deleteAll([
          garment.imagePath,
          garment.thumbPath,
          // La original pesa mas que el recorte y la miniatura juntos:
          // olvidarla dejaba megas muertos por cada prenda borrada.
          garment.originalPath,
        ]);
        await ref.read(catalogRepositoryProvider).pruneOrphanTags();
        ref.invalidate(washCandidatesProvider);

        if (context.mounted) context.pop();
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  /// Lavadas y desgaste. Los usos por lavada son la medida de cuánto aguanta
  /// la prenda: cuantos más usos por lavada, menos desgaste acumula.
  String _washSummary(Garment g) {
    if (g.washCount == 0) return 'nunca';
    final ratio = g.wearsPerWash;
    if (ratio == null) return '${g.washCount}';
    final shown = ratio.toStringAsFixed(1);
    final clean = shown.endsWith('.0')
        ? shown.substring(0, shown.length - 2)
        : shown;
    return '${g.washCount}  ·  $clean usos por lavada';
  }
}

/// Edición: reutiliza el mismo formulario del alta, sin volver a pasar por
/// cámara, recorte ni segmentación.
class _EditGarmentScreen extends ConsumerWidget {
  const _EditGarmentScreen({required this.garment});

  final Garment garment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar prenda')),
      body: TagForm(
        imageWidget: GarmentImage(garment: garment, useThumb: false),
        palette: PaletteResult(
          dominant: garment.dominantColorArgb,
          palette: garment.palette,
        ),
        saveLabel: 'Guardar cambios',
        initial: GarmentTagging(
          categoryId: garment.category.id,
          colorArgb: garment.dominantColorArgb,
          name: garment.name,
          brand: garment.brand,
          notes: garment.notes,
          seasons: garment.seasons,
          occasionIds: garment.occasions.map((o) => o.id).toSet(),
          moodIds: garment.moods.map((m) => m.id).toSet(),
          tags: garment.tags,
          washGroupId: garment.washGroup?.id,
          isFavorite: garment.isFavorite,
        ),
        onSave: (values) async {
          await ref
              .read(garmentRepositoryProvider)
              .update(
                garment.id,
                GarmentDraft(
                  // Las imágenes no cambian al editar los datos.
                  imagePath: garment.imagePath,
                  thumbPath: garment.thumbPath,
                  categoryId: values.categoryId,
                  dominantColorArgb: values.colorArgb,
                  palette: garment.palette,
                  name: values.name,
                  brand: values.brand,
                  notes: values.notes,
                  seasons: values.seasons,
                  occasionIds: values.occasionIds,
                  moodIds: values.moodIds,
                  tags: values.tags,
                  washGroupId: values.washGroupId,
                  isFavorite: values.isFavorite,
                ),
              );
          await ref.read(catalogRepositoryProvider).pruneOrphanTags();
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

/// Aviso de que la prenda se uso despues de su ultima lavada.
class _DirtyBanner extends StatelessWidget {
  const _DirtyBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_laundry_service_outlined,
            color: scheme.onTertiaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'La usaste despues de la ultima lavada.',
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/laundry'),
            child: const Text('Lavar'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(child: Text(value)),
          ?trailing,
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final v in values)
                  Chip(label: Text(v), visualDensity: VisualDensity.compact),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
