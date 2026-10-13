import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../share/outfit_share.dart';
import '../../domain/models/outfit.dart';
import '../../ui/garment_image.dart';

class SavedOutfitsScreen extends ConsumerWidget {
  const SavedOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfits = ref.watch(savedOutfitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Guardados')),
      body: outfits.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    const Text(
                      'Aun no has guardado ningun outfit.\nGuardalos desde la '
                      'pestana de Outfits.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: items.length,
            itemBuilder: (_, i) => _SavedCard(outfit: items[i]),
          );
        },
      ),
    );
  }
}

/// Registra un outfit como puesto en un dia pasado.
///
/// Se apoya en el calendario: un dia con outfit marcado ES el registro, asi
/// que no hace falta un segundo historial que pudiera contradecirlo.
Future<void> _logOnDay(
    BuildContext context, WidgetRef ref, SavedOutfit outfit) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: DateTime(now.year - 2),
    lastDate: now,
    helpText: 'Cuando te lo pusiste',
  );
  if (picked == null) return;

  final plans = ref.read(planRepositoryProvider);
  final planId = await plans.addPlan(picked, outfit: outfit);
  await plans.markWorn(planId);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registrado el ${picked.day}/${picked.month}')),
    );
  }
}

class _SavedCard extends ConsumerWidget {
  const _SavedCard({required this.outfit});

  final SavedOutfit outfit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: outfit.isFavorite ? 'Quitar favorito' : 'Favorito',
                  icon: Icon(
                    outfit.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: outfit.isFavorite ? Colors.red : null,
                    size: 20,
                  ),
                  onPressed: () => ref
                      .read(outfitRepositoryProvider)
                      .setFavorite(outfit.id, !outfit.isFavorite),
                ),
                Expanded(
                  child: Text(
                    outfit.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (outfit.wearCount > 0)
                  Text('Puesto ${outfit.wearCount}x',
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: Row(
                children: [
                  for (final g in outfit.items)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/garment/${g.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: GarmentImage(garment: g),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    // Marcar el outfit propaga el uso a cada prenda, que es
                    // lo que alimenta la penalizacion por repeticion del
                    // motor.
                    await ref
                        .read(outfitRepositoryProvider)
                        .markWorn(outfit.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marcado como puesto')),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Puesto hoy'),
                ),
                TextButton.icon(
                  onPressed: () => _logOnDay(context, ref, outfit),
                  icon: const Icon(Icons.event_outlined),
                  label: const Text('Otro dia'),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Compartir',
                  icon: const Icon(Icons.ios_share_rounded),
                  onPressed: () => shareOutfit(context, ref, outfit.items,
                      title: outfit.name ?? outfit.occasion?.name),
                ),
                IconButton(
                  tooltip: 'Borrar',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      ref.read(outfitRepositoryProvider).delete(outfit.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
