import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/catalog.dart';
import '../../ui/labels.dart';

/// Gestión de los catálogos editables: tipos de prenda, ocasiones y moods.
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Etiquetas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tipos'),
              Tab(text: 'Ocasiones'),
              Tab(text: 'Moods'),
              Tab(text: 'Lavado'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CategoriesTab(),
            _OccasionsTab(),
            _MoodsTab(),
            _WashGroupsTab(),
          ],
        ),
      ),
    );
  }
}

// ---- tipos de prenda -------------------------------------------------------

class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoriesProvider).value ?? const [];

    final bySlot = <Slot, List<Category>>{};
    for (final c in cats) {
      bySlot.putIfAbsent(c.slot, () => []).add(c);
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Cada tipo de prenda tiene que decir dónde se lleva. Es lo que '
              'le permite a la app montar outfits: sin eso no sabría si una '
              '"ruana" va encima o debajo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final slot in Slot.values) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text(
                    Labels.slot(slot).toLowerCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Labels.slotHint(slot),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            for (final c in bySlot[slot] ?? const <Category>[])
              _CategoryTile(category: c),
            if ((bySlot[slot] ?? const []).isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text('—'),
              ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editCategory(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo tipo'),
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      title: Text(category.name),
      subtitle: Text(
        '${Labels.scale(Labels.formality, category.formality)} · '
        '${Labels.scale(Labels.warmth, category.warmth)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editCategory(context, ref, category),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteCategory(context, ref, category),
          ),
        ],
      ),
    );
  }
}

Future<void> _editCategory(
    BuildContext context, WidgetRef ref, Category? existing) async {
  final nameCtl = TextEditingController(text: existing?.name ?? '');
  var slot = existing?.slot ?? Slot.top;
  var formality = existing?.formality ?? 2;
  var warmth = existing?.warmth ?? 1;

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Nuevo tipo de prenda' : 'Editar tipo',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtl,
                autofocus: existing == null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ruana, Chaleco, Gorro...',
                ),
              ),
              const SizedBox(height: 20),
              Text('¿Dónde se lleva?',
                  style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 4),
              // Obligatorio: sin ranura el motor no puede componer.
              for (final s in Slot.values)
                RadioListTile<Slot>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: s,
                  // ignore: deprecated_member_use
                  groupValue: slot,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => slot = v!),
                  title: Text(Labels.slot(s)),
                  subtitle: Text(Labels.slotHint(s),
                      style: Theme.of(ctx).textTheme.bodySmall),
                ),
              const SizedBox(height: 12),
              _ScaleSlider(
                label: 'Formalidad',
                table: Labels.formality,
                value: formality,
                onChanged: (v) => setState(() => formality = v),
              ),
              _ScaleSlider(
                label: 'Abrigo',
                table: Labels.warmth,
                value: warmth,
                onChanged: (v) => setState(() => warmth = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Guardar'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );

  if (saved != true) return;
  final name = nameCtl.text.trim();
  if (name.isEmpty) return;

  final repo = ref.read(catalogRepositoryProvider);
  try {
    if (existing == null) {
      await repo.createCategory(
          name: name, slot: slot, formality: formality, warmth: warmth);
    } else {
      await repo.updateCategory(existing.copyWith(
          name: name, slot: slot, formality: formality, warmth: warmth));
    }
  } catch (_) {
    // El nombre es único en la base: el único fallo esperable aquí es un
    // duplicado, y decirlo así es más útil que enseñar la excepción.
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya existe un tipo llamado "$name".')),
      );
    }
  }
}

Future<void> _deleteCategory(
    BuildContext context, WidgetRef ref, Category category) async {
  final repo = ref.read(catalogRepositoryProvider);
  final inUse = await repo.garmentsInCategory(category.id);
  if (!context.mounted) return;

  final all = ref.read(categoriesProvider).value ?? const <Category>[];
  final targets = all.where((c) => c.id != category.id).toList();
  var reassignTo = targets
      .where((c) => c.name == CatalogSeed.fallbackCategory)
      .firstOrNull
      ?.id;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text('Borrar "${category.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (inUse == 0)
              const Text('No hay ninguna prenda de este tipo.')
            else ...[
              Text('Hay $inUse ${inUse == 1 ? 'prenda' : 'prendas'} de este '
                  'tipo. No se van a borrar: elige a dónde pasan.'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: reassignTo,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Moverlas a'),
                items: [
                  for (final c in targets)
                    DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.name}  (${Labels.slot(c.slot)})'),
                    ),
                ],
                onChanged: (v) => setState(() => reassignTo = v),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Borrar')),
        ],
      ),
    ),
  );

  if (confirmed != true) return;
  await repo.deleteCategory(category.id, reassignTo: reassignTo);
}

class _ScaleSlider extends StatelessWidget {
  const _ScaleSlider({
    required this.label,
    required this.table,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> table;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${Labels.scale(table, value)}',
            style: Theme.of(context).textTheme.labelLarge),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: (table.length - 1).toDouble(),
          divisions: table.length - 1,
          label: Labels.scale(table, value),
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}

// ---- ocasiones -------------------------------------------------------------

class _OccasionsTab extends ConsumerWidget {
  const _OccasionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occs = ref.watch(occasionsProvider).value ?? const [];
    final repo = ref.read(catalogRepositoryProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Para qué sirve una prenda. Borrar una ocasión no borra ropa: '
              'solo deja de estar etiquetada con ella.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final o in occs)
            ListTile(
              dense: true,
              title: Text(o.name),
              subtitle: Text(Labels.scale(Labels.formality, o.formality)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editOccasion(context, ref, o),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => repo.deleteOccasion(o.id),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editOccasion(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Nueva ocasión'),
      ),
    );
  }
}

Future<void> _editOccasion(
    BuildContext context, WidgetRef ref, Occasion? existing) async {
  final ctl = TextEditingController(text: existing?.name ?? '');
  var formality = existing?.formality ?? 2;

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(existing == null ? 'Nueva ocasión' : 'Editar ocasión',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: ctl,
              autofocus: existing == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Universidad, Iglesia, Rumba...',
              ),
            ),
            const SizedBox(height: 16),
            _ScaleSlider(
              label: 'Qué tan arreglado',
              table: Labels.formality,
              value: formality,
              onChanged: (v) => setState(() => formality = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Guardar'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );

  if (saved != true || ctl.text.trim().isEmpty) return;
  final repo = ref.read(catalogRepositoryProvider);
  try {
    if (existing == null) {
      await repo.createOccasion(name: ctl.text, formality: formality);
    } else {
      await repo.updateOccasion(
          existing.copyWith(name: ctl.text, formality: formality));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya existe "${ctl.text.trim()}".')),
      );
    }
  }
}

// ---- grupos de lavado ------------------------------------------------------

class _WashGroupsTab extends ConsumerWidget {
  const _WashGroupsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(washGroupsProvider).value ?? const <WashGroup>[];
    final repo = ref.read(washGroupRepositoryProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Con qué carga va cada prenda a la lavadora. Borrar un grupo no '
              'borra ropa: las prendas se quedan sin clasificar.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final g in groups)
            ListTile(
              dense: true,
              title: Text(g.name),
              subtitle: FutureBuilder<int>(
                future: repo.garmentsIn(g.id),
                builder: (_, snap) => Text(snap.data == null
                    ? ''
                    : '${snap.data} '
                        '${snap.data == 1 ? 'prenda' : 'prendas'}'),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editWashGroup(context, ref, g),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => repo.delete(g.id),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editWashGroup(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo grupo'),
      ),
    );
  }
}

Future<void> _editWashGroup(
    BuildContext context, WidgetRef ref, WashGroup? existing) async {
  final ctl = TextEditingController(text: existing?.name ?? '');

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? 'Nuevo grupo' : 'Editar grupo'),
      content: TextField(
        controller: ctl,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Nombre',
          hintText: 'Blancos, Toallas, Lana...',
        ),
        onSubmitted: (_) => Navigator.pop(ctx, true),
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
  );

  if (ok != true || ctl.text.trim().isEmpty) return;
  final repo = ref.read(washGroupRepositoryProvider);
  try {
    if (existing == null) {
      await repo.create(ctl.text);
    } else {
      await repo.update(existing.copyWith(name: ctl.text));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya existe "${ctl.text.trim()}".')),
      );
    }
  }
}

// ---- moods -----------------------------------------------------------------

class _MoodsTab extends ConsumerWidget {
  const _MoodsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moods = ref.watch(moodsProvider).value ?? const [];
    final repo = ref.read(catalogRepositoryProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'El rollo de una prenda. La app premia los outfits cuyas '
              'prendas comparten mood.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final m in moods)
            ListTile(
              dense: true,
              title: Text(m.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editMood(context, ref, m),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => repo.deleteMood(m.id),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editMood(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo mood'),
      ),
    );
  }
}

Future<void> _editMood(
    BuildContext context, WidgetRef ref, Mood? existing) async {
  final ctl = TextEditingController(text: existing?.name ?? '');

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? 'Nuevo mood' : 'Editar mood'),
      content: TextField(
        controller: ctl,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Nombre',
          hintText: 'Playero, Ejecutivo, Vintage...',
        ),
        onSubmitted: (_) => Navigator.pop(ctx, true),
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
  );

  if (saved != true || ctl.text.trim().isEmpty) return;
  final repo = ref.read(catalogRepositoryProvider);
  try {
    if (existing == null) {
      await repo.createMood(ctl.text);
    } else {
      await repo.updateMood(existing.copyWith(name: ctl.text));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya existe "${ctl.text.trim()}".')),
      );
    }
  }
}
