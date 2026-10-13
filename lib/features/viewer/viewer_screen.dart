import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;

import '../../app/providers.dart';
import '../../domain/models/catalog.dart';
import '../share/outfit_share.dart';

/// Una prenda tal como llega del servidor.
class RemoteGarment {
  RemoteGarment(Map raw)
      : id = (raw['localId'] as num).toInt(),
        data = Map<String, dynamic>.from(raw['data'] as Map),
        thumbUrl = raw['thumbUrl'] as String?,
        imageUrl = raw['imageUrl'] as String?;

  final int id;
  final Map<String, dynamic> data;
  final String? thumbUrl;
  final String? imageUrl;

  String get name => data['name'] as String? ?? '';
  String get category => data['category'] as String? ?? '';
  bool get archived => data['archived'] as bool? ?? false;
  Slot get slot =>
      Slot.values.where((v) => v.name == data['slot']).firstOrNull ??
      Slot.accessory;
  List<String> list(String key) =>
      ((data[key] as List?) ?? const []).cast<String>();
}

class RemoteCloset {
  RemoteCloset(Map raw)
      : ownerName = raw['ownerName'] as String? ?? '',
        garments = [
          for (final g in (raw['garments'] as List).cast<Map>())
            RemoteGarment(g),
        ],
        outfits = [
          for (final o in (raw['outfits'] as List).cast<Map>())
            Map<String, dynamic>.from(o['data'] as Map),
        ],
        looks = [
          for (final l in (raw['looks'] as List).cast<Map>())
            {
              ...Map<String, dynamic>.from(l['data'] as Map),
              'photoUrl': l['photoUrl'],
            },
        ];

  final String ownerName;
  final List<RemoteGarment> garments;
  final List<Map<String, dynamic>> outfits;
  final List<Map<String, dynamic>> looks;

  RemoteGarment? byId(int id) =>
      garments.where((g) => g.id == id).firstOrNull;
}

final remoteClosetProvider =
    FutureProvider.autoDispose.family<RemoteCloset, String>((ref, id) async {
  final raw =
      await ref.read(convexProvider).query('view:closet', {'closetId': id});
  return RemoteCloset(raw as Map);
});

/// El armario de otra persona, en solo lectura.
///
/// Deliberadamente sencillo: ver la ropa, sus outfits y su diario. Todo lo
/// que cambia datos (marcar puesto, lavar, editar) es del dueno.
class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({super.key, required this.closetId});

  final String closetId;

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

/// Lo que se va eligiendo para armar un outfit con la ropa del otro.
///
/// El visor no puede guardar nada en el armario ajeno, asi que el outfit
/// armado no se guarda: se convierte en una imagen para mandarsela. Es la
/// forma de decir "ponte esto" sin tocar sus datos.
class _ViewerScreenState extends ConsumerState<ViewerScreen>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 3, vsync: this);
  final _picked = <int>[];
  var _picking = false;
  var _sharing = false;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _toggle(int id) => setState(() {
        if (!_picked.remove(id)) _picked.add(id);
      });

  /// Parte de un outfit suyo: lo trae al modo de armar para cambiarle piezas.
  void _startFrom(List ids) {
    setState(() {
      _picking = true;
      _picked
        ..clear()
        ..addAll([for (final id in ids) (id as num).toInt()]);
    });
    _tabs.animateTo(0);
  }

  Future<void> _share(RemoteCloset closet, List<int> ids,
      {String? title}) async {
    setState(() => _sharing = true);
    try {
      await shareCollage(context, [
        for (final id in ids)
          if (closet.byId(id) case final g? when g.imageUrl != null)
            (
              slot: g.slot,
              load: () async => (await http.get(Uri.parse(g.imageUrl!))).bodyBytes,
            ),
      ], title: title);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final closet = ref.watch(remoteClosetProvider(widget.closetId));
    final c = closet.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(c == null ? 'Armario compartido' : 'Armario de ${c.ownerName}'),
        bottom: TabBar(controller: _tabs, tabs: const [
          Tab(text: 'Prendas'),
          Tab(text: 'Outfits'),
          Tab(text: 'Diario'),
        ]),
      ),
      floatingActionButton: c == null || _picking
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _picking = true;
                  _picked.clear();
                });
                _tabs.animateTo(0);
              },
              icon: const Icon(Icons.dashboard_customize_outlined),
              label: const Text('Armar outfit'),
            ),
      bottomNavigationBar: c == null || !_picking
          ? null
          : _PickBar(
              closet: c,
              picked: _picked,
              sharing: _sharing,
              onCancel: () => setState(() {
                _picking = false;
                _picked.clear();
              }),
              onShare: () => _share(c, _picked),
            ),
      body: closet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudo cargar: $e', textAlign: TextAlign.center),
          ),
        ),
        data: (c) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(remoteClosetProvider(widget.closetId).future),
          child: TabBarView(controller: _tabs, children: [
            _Garments(
              closet: c,
              picking: _picking,
              picked: _picked,
              onPick: _toggle,
            ),
            _Outfits(
              closet: c,
              onShare: (o) => _share(
                c,
                [for (final id in o['garments'] as List? ?? const []) (id as num).toInt()],
                title: o['name'] as String?,
              ),
              onStartFrom: (o) => _startFrom(o['garments'] as List? ?? const []),
            ),
            _Looks(closet: c),
          ]),
        ),
      ),
    );
  }
}

/// Barra inferior del modo de armar: lo elegido y el boton de compartir.
class _PickBar extends StatelessWidget {
  const _PickBar({
    required this.closet,
    required this.picked,
    required this.sharing,
    required this.onCancel,
    required this.onShare,
  });

  final RemoteCloset closet;
  final List<int> picked;
  final bool sharing;
  final VoidCallback onCancel;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Cancelar',
                icon: const Icon(Icons.close),
                onPressed: onCancel,
              ),
              Expanded(
                child: picked.isEmpty
                    ? const Text('Toca prendas para armar el outfit')
                    : SizedBox(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final id in picked)
                              if (closet.byId(id) case final g?)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: SizedBox(
                                      width: 44, child: _NetImage(url: g.thumbUrl)),
                                ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: picked.isEmpty || sharing ? null : onShare,
                icon: sharing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.ios_share_rounded),
                label: const Text('Compartir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Garments extends StatefulWidget {
  const _Garments({
    required this.closet,
    required this.picking,
    required this.picked,
    required this.onPick,
  });

  final RemoteCloset closet;
  final bool picking;
  final List<int> picked;
  final void Function(int id) onPick;

  @override
  State<_Garments> createState() => _GarmentsState();
}

class _GarmentsState extends State<_Garments> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final visible = [
      for (final g in widget.closet.garments)
        if (!g.archived &&
            (q.isEmpty ||
                g.name.toLowerCase().contains(q) ||
                g.category.toLowerCase().contains(q) ||
                g.list('tags').any((t) => t.toLowerCase().contains(q))))
          g,
    ];
    final byCategory = <String, List<RemoteGarment>>{};
    for (final g in visible) {
      byCategory.putIfAbsent(g.category, () => []).add(g);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No hay prendas que mostrar.')),
          ),
        for (final e in byCategory.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('${e.key} · ${e.value.length}',
                style: Theme.of(context).textTheme.titleSmall),
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final g in e.value)
                InkWell(
                  onTap: () => widget.picking
                      ? widget.onPick(g.id)
                      : _detail(context, g),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: widget.picked.contains(g.id)
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3)
                          : null,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: _NetImage(url: g.thumbUrl),
                        ),
                        if (widget.picked.contains(g.id))
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  void _detail(BuildContext context, RemoteGarment g) {
    final chips = [
      ...g.list('seasons'),
      ...g.list('occasions'),
      ...g.list('moods'),
      ...g.list('tags').map((t) => '#$t'),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 320, child: Center(child: _NetImage(url: g.imageUrl))),
              const SizedBox(height: 16),
              Text(g.name, style: Theme.of(context).textTheme.titleLarge),
              Text([
                g.category,
                if (g.data['brand'] != null) g.data['brand'],
              ].join(' · ')),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final c in chips) Chip(label: Text(c)),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Outfits extends StatelessWidget {
  const _Outfits({
    required this.closet,
    required this.onShare,
    required this.onStartFrom,
  });

  final RemoteCloset closet;
  final void Function(Map<String, dynamic> outfit) onShare;
  final void Function(Map<String, dynamic> outfit) onStartFrom;

  @override
  Widget build(BuildContext context) {
    if (closet.outfits.isEmpty) {
      return const Center(child: Text('Todavía no hay outfits guardados.'));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final o in closet.outfits)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o['name'] as String? ?? 'Outfit',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _Strip(closet: closet, ids: o['garments'] as List? ?? const []),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => onStartFrom(o),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Usar como base'),
                      ),
                      TextButton.icon(
                        onPressed: () => onShare(o),
                        icon: const Icon(Icons.ios_share_rounded, size: 18),
                        label: const Text('Compartir'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Looks extends StatelessWidget {
  const _Looks({required this.closet});

  final RemoteCloset closet;

  @override
  Widget build(BuildContext context) {
    final worn = [
      for (final l in closet.looks)
        if (l['worn'] == true) l,
    ]..sort((a, b) => (b['day'] as num).compareTo(a['day'] as num));
    if (worn.isEmpty) {
      return const Center(child: Text('Todavía no hay looks en el diario.'));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final l in worn)
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (l['photoUrl'] != null)
                  AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Image.network(l['photoUrl'] as String,
                        fit: BoxFit.cover, cacheWidth: 900),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_date(DateTime.fromMillisecondsSinceEpoch(
                          (l['day'] as num).toInt()))),
                      const SizedBox(height: 8),
                      _Strip(
                          closet: closet,
                          ids: l['garments'] as List? ?? const []),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Strip extends StatelessWidget {
  const _Strip({required this.closet, required this.ids});

  final RemoteCloset closet;
  final List ids;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final id in ids) ?closet.byId((id as num).toInt()),
    ];
    return SizedBox(
      height: 96,
      child: Row(
        children: [
          for (final g in items)
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(3),
              child: _NetImage(url: g.thumbUrl),
            )),
        ],
      ),
    );
  }
}

class _NetImage extends StatelessWidget {
  const _NetImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null) return const Icon(Icons.image_not_supported_outlined);
    return Image.network(
      u,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
    );
  }
}
