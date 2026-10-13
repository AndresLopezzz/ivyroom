import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/intake/garment_intake.dart';
import '../../domain/color/color_extractor.dart';
import '../../domain/models/catalog.dart';
import '../../ui/design/components.dart';
import '../../ui/garment_image.dart';
import '../../ui/labels.dart';

/// Formulario de etiquetado. Sirve tanto para el alta como para la edición.
///
/// Devuelve un [GarmentTagging] ya resuelto a ids de catálogo, para que ni
/// esta pantalla ni el flujo de captura tengan que saber de la base.
class TagForm extends ConsumerStatefulWidget {
  const TagForm({
    super.key,
    required this.palette,
    required this.onSave,
    this.image,
    this.imageWidget,
    this.initial,
    this.saveLabel = 'Guardar prenda',
    this.onEditImage,
  });

  /// PNG a previsualizar en el alta.
  final Uint8List? image;

  /// Alternativa para la edición, donde la imagen ya está en disco.
  final Widget? imageWidget;

  final PaletteResult palette;
  final GarmentTagging? initial;
  final String saveLabel;
  final void Function(GarmentTagging values) onSave;

  /// Si llega, se ofrece "Editar recorte" sobre la imagen. Lo que ya se
  /// escribio en el formulario se conserva al volver.
  final VoidCallback? onEditImage;

  @override
  ConsumerState<TagForm> createState() => _TagFormState();
}

class _TagFormState extends ConsumerState<TagForm> {
  int? _categoryId;
  late int _color;

  /// Si el usuario ya eligió color a mano, una paleta que llegue tarde no
  /// debe pisarle la decisión.
  bool _colorTouched = false;
  late Set<Season> _seasons;
  late Set<int> _occasionIds;
  late Set<int> _moodIds;
  late Set<String> _tags;
  int? _washGroupId;
  late bool _favorite;

  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _notes = TextEditingController();
  final _tagInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _categoryId = i?.categoryId;
    // El color detectado es una propuesta: la iluminación de la foto puede
    // falsear el tono real, así que el usuario manda.
    _color = i?.colorArgb ?? widget.palette.dominant;
    _seasons = {...?i?.seasons};
    _occasionIds = {...?i?.occasionIds};
    _moodIds = {...?i?.moodIds};
    _tags = {...?i?.tags};
    _washGroupId = i?.washGroupId;
    _favorite = i?.isFavorite ?? false;
    _colorTouched = i != null;
    _name.text = i?.name ?? '';
    _brand.text = i?.brand ?? '';
    _notes.text = i?.notes ?? '';
  }

  @override
  void didUpdateWidget(TagForm old) {
    super.didUpdateWidget(old);
    // El color se fija en initState, así que una paleta que llegue después
    // se ignoraría en silencio y la prenda quedaría guardada con el gris de
    // relleno. Paso exactamente eso con las primeras prendas: el formulario
    // se construía antes de que terminara el análisis de color.
    if (!_colorTouched && widget.palette.dominant != old.palette.dominant) {
      setState(() => _color = widget.palette.dominant);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _notes.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final occasions = ref.watch(occasionsProvider).value ?? const [];
    final moods = ref.watch(moodsProvider).value ?? const [];
    final knownTags = ref.watch(tagsProvider).value ?? const [];

    // Si no hay categoría elegida todavía, se propone la primera del
    // catálogo en vez de dejar el desplegable vacío.
    final selected = _categoryId ??
        (categories.isEmpty ? null : categories.first.id);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CheckerboardBackground(
                      child: widget.imageWidget ??
                          Image.memory(widget.image!, fit: BoxFit.contain),
                    ),
                    if (widget.onEditImage != null)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: FilledButton.tonalIcon(
                          onPressed: widget.onEditImage,
                          icon: const Icon(Icons.brush_outlined, size: 18),
                          label: const Text('Editar recorte'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _colorPicker(context),
              const SizedBox(height: 24),
              _categoryPicker(context, categories, selected),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre (opcional)',
                  hintText: 'Camisa de lino beige',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _brand,
                textCapitalization: TextCapitalization.words,
                decoration:
                    const InputDecoration(labelText: 'Marca (opcional)'),
              ),
              const SizedBox(height: 24),
              _seasonChips(context),
              _catalogChips<Occasion>(
                context,
                title: 'Ocasión',
                items: occasions,
                idOf: (o) => o.id,
                nameOf: (o) => o.name,
                selected: _occasionIds,
                onToggle: (id) => setState(() => _flip(_occasionIds, id)),
                onCreate: (name) async {
                  final id = await ref
                      .read(catalogRepositoryProvider)
                      .createOccasion(name: name);
                  if (mounted) setState(() => _occasionIds.add(id));
                },
                createHint: 'Universidad, Rumba...',
              ),
              _catalogChips<Mood>(
                context,
                title: 'Mood',
                items: moods,
                idOf: (m) => m.id,
                nameOf: (m) => m.name,
                selected: _moodIds,
                onToggle: (id) => setState(() => _flip(_moodIds, id)),
                onCreate: (name) async {
                  final id = await ref
                      .read(catalogRepositoryProvider)
                      .createMood(name);
                  if (mounted) setState(() => _moodIds.add(id));
                },
                createHint: 'Playero, Vintage...',
              ),
              _washGroupPicker(context),
              _tagEditor(context, knownTags),
              const SizedBox(height: 16),
              TextField(
                controller: _notes,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    const InputDecoration(labelText: 'Notas (opcional)'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Favorita'),
                value: _favorite,
                onChanged: (v) => setState(() => _favorite = v),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: selected == null ? null : () => _submit(selected),
                child: Text(widget.saveLabel),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryPicker(
      BuildContext context, List<Category> categories, int? selected) {
    // Agrupado por ranura para que se vea de un vistazo dónde va cada tipo.
    final bySlot = <Slot, List<Category>>{};
    for (final c in categories) {
      bySlot.putIfAbsent(c.slot, () => []).add(c);
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Tipo de prenda'),
            items: [
              for (final slot in Slot.values)
                if (bySlot[slot]?.isNotEmpty ?? false)
                  ...bySlot[slot]!.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.name}  ·  ${Labels.slot(c.slot)}'),
                      )),
            ],
            onChanged: (v) => setState(() => _categoryId = v),
          ),
        ),
        IconButton(
          tooltip: 'Crear un tipo nuevo',
          icon: const Icon(Icons.add_circle_outline),
          onPressed: _createCategory,
        ),
      ],
    );
  }

  /// Crear una categoría desde el alta: obliga a elegir ranura, igual que en
  /// la pantalla de etiquetas.
  Future<void> _createCategory() async {
    final nameCtl = TextEditingController();
    var slot = Slot.top;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Nuevo tipo de prenda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ruana, Chaleco...',
                  ),
                ),
                const SizedBox(height: 16),
                Text('¿Dónde se lleva?',
                    style: Theme.of(ctx).textTheme.labelLarge),
                for (final s in Slot.values)
                  RadioListTile<Slot>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: s,
                    // ignore: deprecated_member_use
                    groupValue: slot,
                    // ignore: deprecated_member_use
                    onChanged: (v) => setLocal(() => slot = v!),
                    title: Text(Labels.slot(s)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Crear')),
          ],
        ),
      ),
    );

    if (ok != true || nameCtl.text.trim().isEmpty) return;
    try {
      final id = await ref
          .read(catalogRepositoryProvider)
          .createCategory(name: nameCtl.text, slot: slot);
      if (mounted) setState(() => _categoryId = id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ya existe "${nameCtl.text.trim()}".')),
        );
      }
    }
  }

  Widget _colorPicker(BuildContext context) {
    // La paleta detectada más los neutros habituales: cubre casi todo sin
    // meter un selector de color completo.
    final options = <int>{
      ...widget.palette.palette.isEmpty
          ? [widget.palette.dominant]
          : widget.palette.palette,
      _color,
      0xFF000000,
      0xFFFFFFFF,
      0xFF808080,
      0xFF8B6F47,
      0xFF1E3A5F,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color principal',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in options)
              GestureDetector(
                onTap: () => setState(() {
                  _color = c;
                  _colorTouched = true;
                }),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _color == c
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      width: _color == c ? 3 : 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Con que carga va a la lavadora. Es opcional: obligar a clasificar cada
  /// prenda al darla de alta seria friccion, y el registro de lavado
  /// funciona igual sin ello.
  Widget _washGroupPicker(BuildContext context) {
    final groups = ref.watch(washGroupsProvider).value ?? const <WashGroup>[];
    if (groups.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grupo de lavado',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final g in groups)
                Pill(
                  label: g.name,
                  selected: _washGroupId == g.id,
                  tone: PillTone.onSurface,
                  onTap: () => setState(() =>
                      _washGroupId = _washGroupId == g.id ? null : g.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seasonChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Temporada', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final s in Season.values)
                Pill(
                  label: Labels.season(s),
                  selected: _seasons.contains(s),
                  tone: PillTone.onSurface,
                  onTap: () => setState(() => _flip(_seasons, s)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Chips de un catálogo editable, con un botón para crear una entrada
  /// nueva sin salir del formulario.
  Widget _catalogChips<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required int Function(T) idOf,
    required String Function(T) nameOf,
    required Set<int> selected,
    required void Function(int) onToggle,
    required Future<void> Function(String) onCreate,
    required String createHint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final item in items)
                Pill(
                  label: nameOf(item),
                  selected: selected.contains(idOf(item)),
                  tone: PillTone.onSurface,
                  onTap: () => onToggle(idOf(item)),
                ),
              Pill(
                icon: Icons.add_rounded,
                label: 'Nueva',
                onTap: () async {
                  final name = await _askName(title, createHint);
                  if (name != null) await onCreate(name);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _askName(String title, String hint) async {
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nueva ${title.toLowerCase()}'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: 'Nombre', hintText: hint),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Crear')),
        ],
      ),
    );
    final name = ctl.text.trim();
    return (ok == true && name.isNotEmpty) ? name : null;
  }

  Widget _tagEditor(BuildContext context, List<Tag> known) {
    // Los tags ya usados en otras prendas se ofrecen como sugerencia: evita
    // acabar con "playa", "Playa" y "playita" como tres cosas distintas.
    final suggestions = known
        .map((t) => t.name)
        .where((n) => !_tags.contains(n))
        .take(12)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final t in _tags)
                InputChip(
                  label: Text(t),
                  onDeleted: () => setState(() => _tags.remove(t)),
                ),
            ],
          ),
        TextField(
          controller: _tagInput,
          decoration: InputDecoration(
            hintText: 'Añadir tag',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTag,
            ),
          ),
          onSubmitted: (_) => _addTag(),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 2,
            children: [
              for (final s in suggestions)
                ActionChip(
                  label: Text(s),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _tags.add(s)),
                ),
            ],
          ),
        ],
      ],
    );
  }

  void _addTag() {
    final raw = _tagInput.text.trim().toLowerCase();
    if (raw.isEmpty) return;
    setState(() {
      _tags.add(raw);
      _tagInput.clear();
    });
  }

  void _flip<T>(Set<T> set, T value) {
    if (!set.remove(value)) set.add(value);
  }

  void _submit(int categoryId) {
    String? clean(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();

    widget.onSave(GarmentTagging(
      categoryId: categoryId,
      colorArgb: _color,
      name: clean(_name),
      brand: clean(_brand),
      notes: clean(_notes),
      seasons: _seasons,
      occasionIds: _occasionIds,
      moodIds: _moodIds,
      tags: _tags,
      washGroupId: _washGroupId,
      isFavorite: _favorite,
    ));
  }
}
