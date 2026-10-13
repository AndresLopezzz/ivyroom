import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/repos/laundry_repository.dart';
import '../../domain/models/catalog.dart';
import '../../ui/design/components.dart';
import '../../ui/design/motion.dart';
import '../../ui/design/tokens.dart';
import '../../ui/design/type.dart';
import '../../ui/garment_image.dart';

const _months = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String _formatDate(DateTime d) {
  final today = LaundryRepository.dayKey(DateTime.now());
  final key = LaundryRepository.dayKey(d);
  if (key == today) return 'Hoy';
  if (key == today.subtract(const Duration(days: 1))) return 'Ayer';
  return '${d.day} de ${_months[d.month - 1]}';
}

/// Historial de lavadas.
class LaundryScreen extends ConsumerWidget {
  const LaundryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(laundryDaysProvider).value ?? const [];
    final dirty = ref.watch(dirtyCountProvider);
    final top = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.only(top: top + 72, bottom: 140),
          children: [
            _DirtyHeadline(dirty: dirty),
            if (days.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: Ivy.s6),
                child: EmptyState(
                  title: 'Sin lavadas registradas',
                  body: 'Cada vez que laves, apunta qué metiste. La app te '
                      'dirá cuándo lavaste cada prenda por última vez y '
                      'cuántas lavadas lleva encima.',
                ),
              )
            else ...[
              const SectionLabel('Historial'),
              for (final day in days) _LaundryCard(day: day),
            ],
          ],
        ),
        Column(
          children: [
            GlassBar(
              padding: EdgeInsets.only(
                top: top + Ivy.s2,
                left: Ivy.gutter,
                right: Ivy.s3,
                bottom: Ivy.s2,
              ),
              child: Row(
                children: [
                  Text('Lavado', style: IvyType.title),
                  const Spacer(),
                  GlyphButton(
                    filled: false,
                    icon: Icons.tune_rounded,
                    tooltip: 'Grupos de lavado',
                    onTap: () => context.push('/catalog'),
                  ),
                ],
              ),
            ),
            const ScrollEdge(),
          ],
        ),
        Positioned(
          left: Ivy.gutter,
          right: Ivy.gutter,
          bottom: 108,
          child: InkButton(
            label: 'Registrar lavada',
            icon: Icons.local_laundry_service_outlined,
            onTap: () => _record(context, ref, DateTime.now()),
          ),
        ),
      ],
    );
  }
}

/// Lo sucio, en grande.
///
/// Es el número que trae a alguien a esta pantalla, así que va primero y con
/// el tamaño de un titular en vez de escondido en una línea de texto.
class _DirtyHeadline extends ConsumerWidget {
  const _DirtyHeadline({required this.dirty});

  final int dirty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Ivy.gutter, Ivy.s4, Ivy.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dirty == 0 ? 'todo' : '$dirty',
            style: IvyType.hero,
          ),
          Text(
            dirty == 0
                ? 'limpio desde la última vez que usaste algo'
                : dirty == 1
                    ? 'prenda usada sin lavar'
                    : 'prendas usadas sin lavar',
            style: IvyType.body.copyWith(color: Ivy.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _LaundryCard extends ConsumerWidget {
  const _LaundryCard({required this.day});

  final LaundryDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = day.byGroup.entries
        .map((e) => '${e.value} ${e.key.toLowerCase()}')
        .join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(Ivy.gutter, 0, Ivy.gutter, Ivy.s3),
      child: IvyCard(
        onTap: () => _record(context, ref, day.day),
        padding: const EdgeInsets.all(Ivy.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_formatDate(day.day), style: IvyType.heading),
                ),
                Text('${day.items.length}', style: IvyType.smallStrong),
                const SizedBox(width: Ivy.s1),
                Text('prendas', style: IvyType.caption),
                Pressable(
                  onTap: () => _confirmDelete(context, ref, day),
                  child: const Padding(
                    padding: EdgeInsets.only(left: Ivy.s3),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: Ivy.inkFaint),
                  ),
                ),
              ],
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(summary, style: IvyType.caption),
            ],
            if (day.notes != null) ...[
              const SizedBox(height: Ivy.s1),
              Text(day.notes!, style: IvyType.small),
            ],
            const SizedBox(height: Ivy.s3),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: day.items.length,
                separatorBuilder: (_, _) => const SizedBox(width: Ivy.s2),
                itemBuilder: (_, i) => SizedBox(
                  width: 44,
                  child: GarmentImage(garment: day.items[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, LaundryDay day) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar esta lavada'),
        content: const Text(
            'Se descontará de las lavadas de cada prenda que iba dentro.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Borrar')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(laundryRepositoryProvider).deleteDay(day.day);
      ref.invalidate(washCandidatesProvider);
    }
  }
}

Future<void> _record(
    BuildContext context, WidgetRef ref, DateTime day) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => WashPicker(day: day),
  );
}

/// Selector de prendas para una lavada.
///
/// Enseña, por prenda, cuándo se usó y cuándo se lavó por última vez. Ese
/// contexto es todo el punto de la pantalla: la pregunta real al lavar no es
/// "qué tengo" sino "esto ya lo lavé o no".
class WashPicker extends ConsumerStatefulWidget {
  const WashPicker({super.key, required this.day});

  final DateTime day;

  @override
  ConsumerState<WashPicker> createState() => _WashPickerState();
}

class _WashPickerState extends ConsumerState<WashPicker> {
  final _selected = <int>{};
  final _notes = TextEditingController();
  int? _groupFilter;
  bool _onlyDirty = true;
  bool _loaded = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  /// Si se está editando una lavada ya registrada, se parte de lo que tenía.
  Future<void> _loadExisting() async {
    if (_loaded) return;
    _loaded = true;
    final existing =
        await ref.read(laundryRepositoryProvider).forDay(widget.day);
    if (existing == null || !mounted) return;
    setState(() {
      _selected.addAll(existing.items.map((g) => g.id));
      _notes.text = existing.notes ?? '';
      // Al editar interesa ver todo, no solo lo sucio: lo ya registrado
      // aparece como limpio y se escondería.
      _onlyDirty = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadExisting();

    final candidates =
        ref.watch(washCandidatesProvider).value ?? const <WashCandidate>[];
    final groups = ref.watch(washGroupsProvider).value ?? const <WashGroup>[];

    final visible = candidates.where((c) {
      if (_groupFilter != null && c.garment.washGroup?.id != _groupFilter) {
        return false;
      }
      // Lo ya seleccionado se ve siempre, aunque no encaje en el filtro.
      if (_onlyDirty && !c.dirty && !_selected.contains(c.garment.id)) {
        return false;
      }
      return true;
    }).toList();

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        builder: (context, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Ivy.gutter, 0, Ivy.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Qué lavaste', style: IvyType.display),
                  Text(_formatDate(widget.day).toLowerCase(),
                      style: IvyType.body.copyWith(color: Ivy.inkSoft)),
                ],
              ),
            ),
            const SizedBox(height: Ivy.s3),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Ivy.gutter),
                children: [
                  Pill(
                    label: 'Solo sucias',
                    dense: true,
                    selected: _onlyDirty,
                    tone: PillTone.onSurface,
                    onTap: () => setState(() => _onlyDirty = !_onlyDirty),
                  ),
                  const SizedBox(width: Ivy.s2),
                  for (final g in groups) ...[
                    Pill(
                      label: g.name,
                      dense: true,
                      selected: _groupFilter == g.id,
                      tone: PillTone.onSurface,
                      onTap: () => setState(
                          () => _groupFilter = _groupFilter == g.id ? null : g.id),
                    ),
                    const SizedBox(width: Ivy.s2),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Ivy.s2),
            Expanded(
              child: visible.isEmpty
                  ? EmptyState(
                      title: _onlyDirty ? 'Nada sucio' : 'Nada en este grupo',
                      body: _onlyDirty
                          ? 'No hay prendas usadas desde su última lavada. '
                              'Quita "Solo sucias" para ver todo.'
                          : null,
                    )
                  : ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                          horizontal: Ivy.gutter, vertical: Ivy.s2),
                      itemCount: visible.length,
                      itemBuilder: (_, i) => _CandidateTile(
                        candidate: visible[i],
                        selected: _selected.contains(visible[i].garment.id),
                        onTap: () => setState(() {
                          final id = visible[i].garment.id;
                          if (!_selected.remove(id)) _selected.add(id);
                        }),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: Ivy.gutter,
                right: Ivy.gutter,
                top: Ivy.s2,
                bottom: MediaQuery.of(context).viewInsets.bottom + Ivy.s4,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _notes,
                    decoration: const InputDecoration(
                      hintText: 'Notas: agua fría, a mano...',
                    ),
                  ),
                  const SizedBox(height: Ivy.s3),
                  Row(
                    children: [
                      if (_selected.isNotEmpty)
                        Pressable(
                          onTap: () => setState(_selected.clear),
                          child: Padding(
                            padding: const EdgeInsets.all(Ivy.s3),
                            child: Text('Vaciar',
                                style: IvyType.action
                                    .copyWith(color: Ivy.inkSoft)),
                          ),
                        ),
                      const SizedBox(width: Ivy.s2),
                      Expanded(
                        child: InkButton(
                          label: _selected.isEmpty
                              ? 'Elige prendas'
                              : 'Guardar ${_selected.length}',
                          onTap: _selected.isEmpty
                              ? null
                              : () => _save(candidates),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(List<WashCandidate> candidates) async {
    final chosen = [
      for (final c in candidates)
        if (_selected.contains(c.garment.id)) c.garment,
    ];

    await ref.read(laundryRepositoryProvider).record(
          widget.day,
          chosen,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        );
    ref.invalidate(washCandidatesProvider);

    if (mounted) Navigator.pop(context);
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.candidate,
    required this.selected,
    required this.onTap,
  });

  final WashCandidate candidate;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = candidate.garment;

    return Padding(
      padding: const EdgeInsets.only(bottom: Ivy.s2),
      child: IvyCard(
        onTap: onTap,
        color: selected ? Ivy.ink : Ivy.surface,
        padding: const EdgeInsets.all(Ivy.s3),
        radius: Ivy.rCard - 4,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  GarmentImage(garment: g),
                  if (candidate.dirty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Ivy.clay,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Ivy.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: IvyType.bodyStrong.copyWith(
                        color: selected ? Ivy.surface : Ivy.ink),
                  ),
                  Text(
                    _context(),
                    style: IvyType.caption.copyWith(
                      color: selected
                          ? Ivy.surface.withValues(alpha: 0.65)
                          : Ivy.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 22,
              color: selected ? Ivy.surface : Ivy.hairline,
            ),
          ],
        ),
      ),
    );
  }

  /// La línea que contesta la pregunta del usuario sin que tenga que
  /// recordar nada.
  String _context() {
    final parts = <String>[];

    final washed = candidate.daysSinceWashed;
    parts.add(washed == null
        ? 'nunca lavada'
        : washed == 0
            ? 'lavada hoy'
            : 'lavada hace $washed ${washed == 1 ? 'día' : 'días'}');

    final worn = candidate.daysSinceWorn;
    if (worn != null) {
      parts.add(worn == 0
          ? 'usada hoy'
          : 'usada hace $worn ${worn == 1 ? 'día' : 'días'}');
    }

    final group = candidate.garment.washGroup;
    if (group != null) parts.add(group.name.toLowerCase());

    return parts.join(' · ');
  }
}
