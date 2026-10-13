import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/catalog.dart';
import '../../domain/models/garment.dart';
import '../../ui/design/components.dart';
import '../../ui/design/motion.dart';
import '../../ui/design/tokens.dart';
import '../../ui/design/type.dart';
import '../../ui/garment_image.dart';
import '../../ui/labels.dart';
import '../closet/closet_screen.dart' show GarmentTile;

/// Montar un outfit a mano, eligiendo prendas del armario.
///
/// Enseña la puntuación del motor en vivo mientras se elige: son exactamente
/// las mismas reglas que usan las sugerencias automáticas, así que sirve
/// tanto para armar algo como para entender por qué la app propone lo que
/// propone.
class OutfitBuilderScreen extends ConsumerWidget {
  const OutfitBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobe = ref.watch(fullWardrobeProvider).value ?? const [];
    final picked = ref.watch(outfitBuilderProvider);
    final score = ref.watch(outfitBuilderScoreProvider);
    final builder = ref.read(outfitBuilderProvider.notifier);
    final targetDay = ref.watch(builderTargetDayProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + Ivy.s2,
              left: Ivy.s3,
              right: Ivy.s3,
            ),
            child: Row(
              children: [
                GlyphButton(
                  filled: false,
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: Ivy.s1),
                Text(
                  targetDay == null
                      ? 'Armar outfit'
                      : 'Outfit para el ${targetDay.day}',
                  style: IvyType.title,
                ),
                const Spacer(),
                if (picked.isNotEmpty)
                  Pill(
                    label: 'Vaciar',
                    dense: true,
                    onTap: builder.clear,
                  ),
                const SizedBox(width: Ivy.s2),
              ],
            ),
          ),
          _Tray(picked: picked, score: score),
          Expanded(
            child: wardrobe.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Tu armario está vacío. Añade prendas primero.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _Picker(wardrobe: wardrobe, picked: picked),
          ),
        ],
      ),
      bottomNavigationBar: picked.length < 2
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (targetDay != null) ...[
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              _planIt(context, ref, picked, targetDay),
                          icon: const Icon(Icons.event_available_outlined),
                          label: Text('Planificar el ${targetDay.day}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Guardar como outfit',
                        icon: const Icon(Icons.bookmark_add_outlined),
                        onPressed: () => _save(context, ref, picked),
                      ),
                    ] else
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _save(context, ref, picked),
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: Text(
                              'Guardar outfit (${picked.length} prendas)'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Planifica lo elegido directamente en el dia del que se vino.
  ///
  /// Sin guardarlo como outfit: la mayoria de combinaciones son para un dia
  /// concreto y no merecen quedarse en la lista de guardados para siempre.
  Future<void> _planIt(BuildContext context, WidgetRef ref,
      List<Garment> items, DateTime day) async {
    await ref.read(planRepositoryProvider).addPlan(day, garments: items);
    ref.read(outfitBuilderProvider.notifier).clear();
    ref.read(builderTargetDayProvider.notifier).select(null);

    if (context.mounted) {
      context.go('/calendar');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Planificado para el ${day.day}')),
      );
    }
  }

  Future<void> _save(
      BuildContext context, WidgetRef ref, List<Garment> items) async {
    final nameCtl = TextEditingController();
    final occs = ref.read(occasionsProvider).value ?? const <Occasion>[];
    Occasion? occasion;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Guardar outfit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre (opcional)',
                  hintText: 'Para la oficina',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Occasion?>(
                initialValue: occasion,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Ocasión'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Ninguna')),
                  for (final o in occs)
                    DropdownMenuItem(value: o, child: Text(o.name)),
                ],
                onChanged: (v) => setLocal(() => occasion = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Guardar')),
          ],
        ),
      ),
    );

    if (ok != true) return;
    await ref.read(outfitRepositoryProvider).save(
          items,
          name: nameCtl.text.trim().isEmpty ? null : nameCtl.text.trim(),
          occasion: occasion,
        );
    ref.read(outfitBuilderProvider.notifier).clear();
    ref.read(builderTargetDayProvider.notifier).select(null);

    if (context.mounted) {
      context.go('/outfits');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit guardado')),
      );
    }
  }
}

/// Bandeja superior: lo elegido hasta ahora, con hueco por ranura.
class _Tray extends ConsumerWidget {
  const _Tray({required this.picked, required this.score});

  final List<Garment> picked;
  final dynamic score;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final builder = ref.read(outfitBuilderProvider.notifier);
    final bySlot = {for (final g in picked) g.slot: g};

    // Un vestido sustituye a arriba y abajo, así que los huecos que se
    // enseñan cambian según lo que ya haya elegido.
    final slots = bySlot.containsKey(Slot.dress)
        ? [Slot.dress, Slot.outer, Slot.shoes, Slot.accessory]
        : [Slot.top, Slot.bottom, Slot.outer, Slot.shoes, Slot.accessory];

    return Padding(
      padding: const EdgeInsets.fromLTRB(Ivy.s3, Ivy.s3, Ivy.s3, Ivy.s2),
      child: Column(
        children: [
          // Bandeja baja: los huecos son una guia de lo que falta, no el
          // contenido de la pantalla. Alta ocupaba un cuarto del alto sin
          // ensenar nada.
          SizedBox(
            height: 74,
            child: Row(
              children: [
                for (final slot in slots)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _Hole(
                        slot: slot,
                        garment: bySlot[slot],
                        onRemove: bySlot[slot] == null
                            ? null
                            : () => builder.toggle(bySlot[slot]!),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: Ivy.s3),
            _ScoreBar(score: score),
          ],
        ],
      ),
    );
  }
}

class _Hole extends StatelessWidget {
  const _Hole({required this.slot, this.garment, this.onRemove});

  final Slot slot;
  final Garment? garment;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final g = garment;

    return Pressable(
      onTap: onRemove,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Ivy.rThumb + 2),
          // Hueco vacio: relleno tenue en vez de borde. Cinco recuadros
          // perfilados en fila leen como una tabla, y esto es una guia.
          color: g == null ? const Color(0xFFEDEAE4) : Ivy.surface,
        ),
        child: g == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    Labels.slot(slot).toLowerCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: IvyType.caption,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(5),
                child: GarmentImage(garment: g),
              ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.score});

  final dynamic score;

  @override
  Widget build(BuildContext context) {
    final value = (score.score as double).clamp(0.0, 1.0);
    final reasons = (score.reasons as List).cast<String>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(value: value, minHeight: 5),
              ),
            ),
            const SizedBox(width: Ivy.s3),
            Text('${(value * 100).round()}%',
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          reasons.join(' · '),
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Armario navegable por ranura, para elegir.
class _Picker extends StatefulWidget {
  const _Picker({required this.wardrobe, required this.picked});

  final List<Garment> wardrobe;
  final List<Garment> picked;

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  Slot? _slotFilter;

  @override
  Widget build(BuildContext context) {
    final items = _slotFilter == null
        ? widget.wardrobe
        : widget.wardrobe.where((g) => g.slot == _slotFilter).toList();

    return Column(
      children: [
        // Con `Pill` y no con `FilterChip`: el chip de Material pintaba el
        // fondo seleccionado con la tinta del tema pero dejaba la etiqueta
        // del mismo color, asi que el texto desaparecia al elegirlo.
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: Ivy.gutter, vertical: Ivy.s2),
            children: [
              Pill(
                label: 'Todo',
                dense: true,
                selected: _slotFilter == null,
                tone: PillTone.onSurface,
                onTap: () => setState(() => _slotFilter = null),
              ),
              const SizedBox(width: Ivy.s2),
              for (final s in Slot.values) ...[
                Pill(
                  label: Labels.slot(s),
                  dense: true,
                  selected: _slotFilter == s,
                  tone: PillTone.onSurface,
                  onTap: () => setState(
                      () => _slotFilter = _slotFilter == s ? null : s),
                ),
                const SizedBox(width: Ivy.s2),
              ],
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const EmptyState(title: 'Nada de este tipo todavía')
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => Consumer(
                    builder: (context, ref, _) => GarmentTile(
                      garment: items[i],
                      selected: widget.picked.contains(items[i]),
                      onTap: () => ref
                          .read(outfitBuilderProvider.notifier)
                          .toggle(items[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
