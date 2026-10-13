import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/repos/garment_repository.dart';
import '../../domain/models/catalog.dart';
import '../../domain/models/garment.dart';
import '../../ui/design/components.dart';
import '../../ui/design/motion.dart';
import '../../ui/design/tokens.dart';
import '../../ui/design/type.dart';
import '../../ui/garment_image.dart';
import '../../ui/labels.dart';

/// Cómo se presenta el armario.
enum ClosetView {
  /// Por defecto: secciones por categoría. Una rejilla plana con cien
  /// prendas no dice nada; agrupada por tipo se navega de un vistazo.
  sections,

  /// Rejilla continua, útil cuando ya hay un filtro estrecho puesto.
  grid,
}

class ClosetViewNotifier extends Notifier<ClosetView> {
  @override
  ClosetView build() => ClosetView.sections;

  void set(ClosetView v) => state = v;
  void toggle() => state =
      state == ClosetView.sections ? ClosetView.grid : ClosetView.sections;
}

final closetViewProvider =
    NotifierProvider<ClosetViewNotifier, ClosetView>(ClosetViewNotifier.new);

class ClosetScreen extends ConsumerWidget {
  const ClosetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closet = ref.watch(closetProvider);
    final filter = ref.watch(closetFilterProvider);
    final view = ref.watch(closetViewProvider);
    final top = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // El contenido corre por debajo de la barra: la pantalla se lee más
        // alta y se ve que hay más cosas arriba.
        closet.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) =>
              EmptyState(title: 'No se pudo cargar el armario', body: '$e'),
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: top + _chromeHeight(filter) + 8),
                child: EmptyState(
                  title: filter.isEmpty
                      ? 'Tu armario está vacío'
                      : 'Nada encaja con estos filtros',
                  body: filter.isEmpty
                      ? 'Fotografía tu primera prenda y la app se encarga de '
                          'recortarla.'
                      : null,
                  action: filter.isEmpty
                      ? InkButton(
                          label: 'Añadir prenda',
                          icon: Icons.add_a_photo_outlined,
                          expand: false,
                          onTap: () => context.push('/capture'),
                        )
                      : InkButton(
                          label: 'Quitar filtros',
                          tone: InkButtonTone.paper,
                          expand: false,
                          onTap: ref.read(closetFilterProvider.notifier).clear,
                        ),
                ),
              );
            }
            return view == ClosetView.sections
                ? _SectionsView(topInset: top)
                : _GridView(items: items, topInset: top);
          },
        ),
        _TopChrome(filter: filter, view: view),
      ],
    );
  }
}

/// Barra flotante translúcida con el título, la vista y los filtros activos.
/// Filtros que se ven como fichas. El texto de busqueda no cuenta: ya se ve
/// en su propio campo.
bool _hasChips(ClosetFilter f) => !f.copyWith(clearQuery: true).isEmpty;

/// Alto de la barra superior, para que el contenido arranque debajo.
double _chromeHeight(ClosetFilter f) => 72 + 48 + (_hasChips(f) ? 40 : 0);

/// Busqueda en vivo. Encuentra por nombre, marca, tipo, color y etiquetas.
class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final _ctl =
      TextEditingController(text: ref.read(closetFilterProvider).query);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _set(String text) => ref
      .read(closetFilterProvider.notifier)
      .update((f) => text.trim().isEmpty
          ? f.copyWith(clearQuery: true)
          : f.copyWith(query: text));

  @override
  Widget build(BuildContext context) {
    // Si los filtros se limpian desde fuera ("Quitar filtros"), el campo
    // tiene que vaciarse tambien.
    ref.listen(closetFilterProvider.select((f) => f.query), (_, q) {
      if ((q ?? '') != _ctl.text) _ctl.text = q ?? '';
    });

    return Padding(
      padding: const EdgeInsets.only(top: Ivy.s2, right: Ivy.s2),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _ctl,
          onChanged: (t) => setState(() => _set(t)),
          textInputAction: TextInputAction.search,
          style: IvyType.body,
          decoration: InputDecoration(
            hintText: 'Buscar: negro, jean, Zara, oficina...',
            hintStyle: IvyType.small.copyWith(color: Ivy.inkFaint),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _ctl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => setState(() {
                      _ctl.clear();
                      _set('');
                    }),
                  ),
            filled: true,
            fillColor: Ivy.surface,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Ivy.rPill),
              borderSide: const BorderSide(color: Ivy.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Ivy.rPill),
              borderSide: const BorderSide(color: Ivy.hairline),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopChrome extends ConsumerWidget {
  const _TopChrome({required this.filter, required this.view});

  final ClosetFilter filter;
  final ClosetView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(closetProvider).value?.length ?? 0;

    return Column(
      children: [
        GlassBar(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + Ivy.s2,
            left: Ivy.gutter,
            right: Ivy.s3,
            bottom: Ivy.s2,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text('Armario', style: IvyType.title),
                  const SizedBox(width: Ivy.s2),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('$count', style: IvyType.small),
                  ),
                  const Spacer(),
                  GlyphButton(
                    filled: false,
                    icon: view == ClosetView.sections
                        ? Icons.view_agenda_outlined
                        : Icons.grid_view_rounded,
                    tooltip: 'Cambiar vista',
                    onTap: ref.read(closetViewProvider.notifier).toggle,
                  ),
                  GlyphButton(
                    filled: false,
                    icon: Icons.tune_rounded,
                    tooltip: 'Filtrar',
                    badge: _hasChips(filter),
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const FilterSheet(),
                    ),
                  ),
                  GlyphButton(
                    filled: false,
                    icon: Icons.more_horiz_rounded,
                    onTap: () => _menu(context),
                  ),
                ],
              ),
              const _SearchField(),
              if (_hasChips(filter)) _ActiveFilters(filter: filter),
            ],
          ),
        ),
        const ScrollEdge(),
      ],
    );
  }

  Future<void> _menu(BuildContext context) async {
    final route = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (icon, label, path) in const [
              (Icons.sell_outlined, 'Etiquetas y tipos', '/catalog'),
              (Icons.insights_outlined, 'Estadísticas', '/stats'),
              (Icons.settings_outlined, 'Ajustes', '/settings'),
            ])
              ListTile(
                leading: Icon(icon),
                title: Text(label, style: IvyType.body),
                onTap: () => Navigator.pop(ctx, path),
              ),
            const SizedBox(height: Ivy.s3),
          ],
        ),
      ),
    );
    if (route != null && context.mounted) context.push(route);
  }
}

class _ActiveFilters extends ConsumerWidget {
  const _ActiveFilters({required this.filter});

  final ClosetFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(closetFilterProvider.notifier);
    final cats = ref.watch(categoriesProvider).value ?? const [];
    final occs = ref.watch(occasionsProvider).value ?? const [];
    final moods = ref.watch(moodsProvider).value ?? const [];
    final tags = ref.watch(tagsProvider).value ?? const [];
    final washes = ref.watch(washGroupsProvider).value ?? const [];

    String? nameOf(List<dynamic> list, int id) {
      for (final e in list) {
        if (e.id == id) return e.name as String;
      }
      return null;
    }

    Pill chip(String label, VoidCallback onDelete) => Pill(
          label: label,
          tone: PillTone.onSurface,
          dense: true,
          onDelete: onDelete,
        );

    final chips = <Widget>[
      for (final s in filter.slots)
        chip(Labels.slot(s), () => notifier.update((f) => f.toggleSlot(s))),
      for (final id in filter.categoryIds)
        if (nameOf(cats, id) case final n?)
          chip(n, () => notifier.update((f) => f.toggleCategory(id))),
      for (final c in filter.colorFamilies)
        chip(Labels.colorFamily(c),
            () => notifier.update((f) => f.toggleColor(c))),
      for (final s in filter.seasons)
        chip(Labels.season(s), () => notifier.update((f) => f.toggleSeason(s))),
      for (final id in filter.occasionIds)
        if (nameOf(occs, id) case final n?)
          chip(n, () => notifier.update((f) => f.toggleOccasion(id))),
      for (final id in filter.moodIds)
        if (nameOf(moods, id) case final n?)
          chip(n, () => notifier.update((f) => f.toggleMood(id))),
      for (final id in filter.washGroupIds)
        if (nameOf(washes, id) case final n?)
          chip(n, () => notifier.update((f) => f.toggleWashGroup(id))),
      for (final id in filter.tagIds)
        if (nameOf(tags, id) case final n?)
          chip('#$n', () => notifier.update((f) => f.toggleTag(id))),
      if (filter.onlyFavorites)
        chip('Favoritas',
            () => notifier.update((f) => f.copyWith(onlyFavorites: false))),
      if (filter.onlyForgotten)
        chip('Olvidadas',
            () => notifier.update((f) => f.copyWith(onlyForgotten: false))),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: Ivy.s2, bottom: 2),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: chips.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (_, i) => i < chips.length
              ? chips[i]
              : Pill(
                  label: 'Limpiar',
                  icon: Icons.clear_all_rounded,
                  dense: true,
                  onTap: notifier.clear,
                ),
        ),
      ),
    );
  }
}

/// Vista por defecto: una fila horizontal por categoría.
class _SectionsView extends ConsumerWidget {
  const _SectionsView({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(closetSectionsProvider);
    final filter = ref.watch(closetFilterProvider);

    final bySlot = <Slot, List<ClosetSection>>{};
    for (final s in sections) {
      bySlot.putIfAbsent(s.category.slot, () => []).add(s);
    }

    return ListView(
      padding: EdgeInsets.only(
        top: topInset + _chromeHeight(filter),
        bottom: 140,
      ),
      children: [
        for (final slot in Slot.values)
          if (bySlot[slot]?.isNotEmpty ?? false) ...[
            SectionLabel(Labels.slot(slot)),
            for (final section in bySlot[slot]!) _SectionRow(section: section),
          ],
      ],
    );
  }
}

class _SectionRow extends ConsumerWidget {
  const _SectionRow({required this.section});

  final ClosetSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Ivy.gutter, 0, Ivy.s3, Ivy.s2),
          child: Row(
            children: [
              Text(section.category.name, style: IvyType.heading),
              const SizedBox(width: Ivy.s2),
              Text('${section.garments.length}', style: IvyType.caption),
              const Spacer(),
              Pressable(
                onTap: () {
                  ref.read(closetFilterProvider.notifier).set(
                        ClosetFilter(categoryIds: {section.category.id}),
                      );
                  ref.read(closetViewProvider.notifier).set(ClosetView.grid);
                },
                child: Padding(
                  padding: const EdgeInsets.all(Ivy.s2),
                  child: Text('Ver todo',
                      style:
                          IvyType.smallStrong.copyWith(color: Ivy.inkFaint)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Ivy.gutter),
            itemCount: section.garments.length,
            separatorBuilder: (_, _) => const SizedBox(width: Ivy.s2),
            itemBuilder: (_, i) => SizedBox(
              width: 116,
              child: GarmentTile(garment: section.garments[i]),
            ),
          ),
        ),
        const SizedBox(height: Ivy.s5),
      ],
    );
  }
}

class _GridView extends ConsumerWidget {
  const _GridView({required this.items, required this.topInset});

  final List<Garment> items;
  final double topInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(closetFilterProvider);
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        Ivy.gutter,
        topInset + _chromeHeight(filter),
        Ivy.gutter,
        140,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: Ivy.s3,
        crossAxisSpacing: Ivy.s3,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => GarmentTile(garment: items[i]),
    );
  }
}

/// Celda de prenda. Compartida entre la rejilla, las secciones y el creador
/// de outfits, que la usa con `selected` y `onTap` propios.
class GarmentTile extends StatelessWidget {
  const GarmentTile({
    super.key,
    required this.garment,
    this.selected = false,
    this.onTap,
  });

  final Garment garment;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap ?? () => context.push('/garment/${garment.id}'),
      child: AnimatedContainer(
        duration: IvyMotion.fast,
        curve: IvyMotion.curve,
        decoration: BoxDecoration(
          color: Ivy.surface,
          borderRadius: BorderRadius.circular(Ivy.rCard - 4),
          border: Border.all(
            color: selected ? Ivy.ink : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Ivy.s3, Ivy.s3, Ivy.s3, Ivy.s1),
                    child: GarmentImage(garment: garment),
                  ),
                  if (garment.isFavorite)
                    const Positioned(
                      top: Ivy.s2,
                      right: Ivy.s2,
                      child: Icon(Icons.favorite, size: 13, color: Ivy.inkFaint),
                    ),
                  // Punto de aviso: esta prenda se usó y no se ha lavado.
                  if (garment.needsWashing)
                    Positioned(
                      top: Ivy.s2 + 2,
                      left: Ivy.s2 + 2,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Ivy.clay,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (selected)
                    const Positioned(
                      bottom: Ivy.s2,
                      right: Ivy.s2,
                      child: Icon(Icons.check_circle, size: 20, color: Ivy.ink),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Ivy.s3, 0, Ivy.s3, Ivy.s3),
              child: Row(
                children: [
                  ColorDot(garment.dominantColorArgb, size: 9),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      garment.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: IvyType.caption.copyWith(color: Ivy.inkSoft),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hoja de filtros. Los toggles viven en `ClosetFilter`, así que esta
/// pantalla solo decide qué se enseña, no cómo se compone el filtro.
class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search =
        TextEditingController(text: ref.read(closetFilterProvider).query ?? '');
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _applyQuery(String value) {
    ref.read(closetFilterProvider.notifier).update((x) => value.trim().isEmpty
        ? x.copyWith(clearQuery: true)
        : x.copyWith(query: value.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final f = ref.watch(closetFilterProvider);
    final notifier = ref.read(closetFilterProvider.notifier);
    final cats = ref.watch(categoriesProvider).value ?? const [];
    final occs = ref.watch(occasionsProvider).value ?? const [];
    final moods = ref.watch(moodsProvider).value ?? const [];
    final tags = ref.watch(tagsProvider).value ?? const [];
    final washes = ref.watch(washGroupsProvider).value ?? const [];
    final matches = ref.watch(closetProvider).value?.length ?? 0;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, controller) => Column(
          children: [
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(
                    Ivy.gutter, 0, Ivy.gutter, Ivy.s4),
                children: [
                  Text('Filtrar', style: IvyType.display),
                  const SizedBox(height: Ivy.s4),
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o marca',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _search.clear();
                                _applyQuery('');
                              },
                            ),
                    ),
                    onChanged: (v) => setState(() => _applyQuery(v)),
                  ),
                  _Group('Dónde se lleva', [
                    for (final s in Slot.values)
                      Pill(
                        label: Labels.slot(s),
                        selected: f.slots.contains(s),
                        tone: PillTone.onSurface,
                        onTap: () => notifier.update((x) => x.toggleSlot(s)),
                      ),
                  ]),
                  _Group('Tipo de prenda', [
                    for (final c in cats)
                      Pill(
                        label: c.name,
                        selected: f.categoryIds.contains(c.id),
                        tone: PillTone.onSurface,
                        onTap: () =>
                            notifier.update((x) => x.toggleCategory(c.id)),
                      ),
                  ]),
                  _Group('Color', [
                    for (final c in ColorFamily.values)
                      Pill(
                        label: Labels.colorFamily(c),
                        selected: f.colorFamilies.contains(c),
                        tone: PillTone.onSurface,
                        onTap: () => notifier.update((x) => x.toggleColor(c)),
                      ),
                  ]),
                  _Group('Temporada', [
                    for (final s in Season.values)
                      Pill(
                        label: Labels.season(s),
                        selected: f.seasons.contains(s),
                        tone: PillTone.onSurface,
                        onTap: () => notifier.update((x) => x.toggleSeason(s)),
                      ),
                  ]),
                  _Group('Ocasión', [
                    for (final o in occs)
                      Pill(
                        label: o.name,
                        selected: f.occasionIds.contains(o.id),
                        tone: PillTone.onSurface,
                        onTap: () =>
                            notifier.update((x) => x.toggleOccasion(o.id)),
                      ),
                  ]),
                  _Group('Mood', [
                    for (final m in moods)
                      Pill(
                        label: m.name,
                        selected: f.moodIds.contains(m.id),
                        tone: PillTone.onSurface,
                        onTap: () =>
                            notifier.update((x) => x.toggleMood(m.id)),
                      ),
                  ]),
                  _Group('Grupo de lavado', [
                    for (final w in washes)
                      Pill(
                        label: w.name,
                        selected: f.washGroupIds.contains(w.id),
                        tone: PillTone.onSurface,
                        onTap: () =>
                            notifier.update((x) => x.toggleWashGroup(w.id)),
                      ),
                  ]),
                  if (tags.isNotEmpty)
                    _Group('Tags', [
                      for (final t in tags)
                        Pill(
                          label: t.name,
                          selected: f.tagIds.contains(t.id),
                          tone: PillTone.onSurface,
                          onTap: () =>
                              notifier.update((x) => x.toggleTag(t.id)),
                        ),
                    ]),
                  _Group('Otros', [
                    Pill(
                      label: 'Solo favoritas',
                      icon: Icons.favorite_border_rounded,
                      selected: f.onlyFavorites,
                      tone: PillTone.onSurface,
                      onTap: () => notifier.update(
                          (x) => x.copyWith(onlyFavorites: !x.onlyFavorites)),
                    ),
                    Pill(
                      label: 'Olvidadas',
                      icon: Icons.hourglass_bottom_rounded,
                      selected: f.onlyForgotten,
                      tone: PillTone.onSurface,
                      onTap: () => notifier.update(
                          (x) => x.copyWith(onlyForgotten: !x.onlyForgotten)),
                    ),
                    Pill(
                      label: 'Ver archivadas',
                      icon: Icons.inventory_2_outlined,
                      selected: f.includeArchived,
                      tone: PillTone.onSurface,
                      onTap: () => notifier.update((x) =>
                          x.copyWith(includeArchived: !x.includeArchived)),
                    ),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Ivy.gutter, Ivy.s2, Ivy.gutter, Ivy.s4),
              child: Row(
                children: [
                  if (!f.isEmpty)
                    Pressable(
                      onTap: () {
                        _search.clear();
                        notifier.clear();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(Ivy.s3),
                        child: Text('Limpiar',
                            style:
                                IvyType.action.copyWith(color: Ivy.inkSoft)),
                      ),
                    ),
                  const SizedBox(width: Ivy.s2),
                  Expanded(
                    child: InkButton(
                      // El botón dice cuántas prendas hay al otro lado: sin
                      // ese número hay que cerrar la hoja para saber si el
                      // filtro sirvió de algo.
                      label: matches == 1
                          ? 'Ver 1 prenda'
                          : 'Ver $matches prendas',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.title, this.children);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Ivy.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: IvyType.label),
          const SizedBox(height: Ivy.s3),
          Wrap(spacing: Ivy.s2, runSpacing: Ivy.s2, children: children),
        ],
      ),
    );
  }
}
