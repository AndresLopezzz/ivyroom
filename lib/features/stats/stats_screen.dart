import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/stats/wardrobe_stats.dart';
import '../../ui/garment_image.dart';
import '../../ui/labels.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobe = ref.watch(fullWardrobeProvider).value;

    if (wardrobe == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final stats = WardrobeStats(wardrobe);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: stats.total == 0
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Cuando tengas prendas y empieces a marcar lo que te pones, '
                  'aquí verás qué usas de verdad y qué tienes olvidado.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                _Headline(stats: stats),
                if (stats.missingSlots(Labels.slot).isNotEmpty)
                  _MissingSlots(stats: stats),
                _MostWorn(stats: stats),
                _Forgotten(stats: stats),
                _Wear(stats: stats),
                _ColorBreakdown(stats: stats),
                _CategoryBreakdown(stats: stats),
              ],
            ),
    );
  }
}

/// Los tres números que resumen el armario.
class _Headline extends StatelessWidget {
  const _Headline({required this.stats});

  final WardrobeStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = (stats.usedRatio * 100).round();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Metric(value: '${stats.total}', label: 'prendas'),
              _Metric(value: '${stats.totalWears}', label: 'usos'),
              _Metric(
                value: stats.averageWearsPerUsedGarment
                    .toStringAsFixed(1)
                    .replaceAll('.0', ''),
                label: 'usos por prenda',
              ),
              _Metric(value: '${stats.totalWashes}', label: 'lavadas'),
            ],
          ),
          const SizedBox(height: 20),
          Text('Cuánto usas tu armario',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: stats.usedRatio,
              minHeight: 12,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stats.neverWornCount == 0
                ? 'Te has puesto todas tus prendas alguna vez.'
                : 'Usas el $pct % de tu armario. '
                    '${stats.neverWornCount} '
                    '${stats.neverWornCount == 1 ? 'prenda sigue' : 'prendas siguen'} '
                    'sin estrenar.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Aviso de por qué el generador puede no estar proponiendo nada.
class _MissingSlots extends StatelessWidget {
  const _MissingSlots({required this.stats});

  final WardrobeStats stats;

  @override
  Widget build(BuildContext context) {
    final missing = stats.missingSlots(Labels.slot);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: scheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Te falta ${missing.map(Labels.slot).join(' y ').toLowerCase()}. '
                'Sin eso la app no puede montar outfits completos.',
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MostWorn extends StatelessWidget {
  const _MostWorn({required this.stats});

  final WardrobeStats stats;

  @override
  Widget build(BuildContext context) {
    final top = stats.mostWorn(limit: 8);
    if (top.isEmpty) {
      return const _Section(
        title: 'Lo que más usas',
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Todavía no has marcado ninguna prenda como puesta. Usa "La usé '
            'hoy" en el detalle de una prenda, o marca los días en el '
            'calendario.',
          ),
        ),
      );
    }

    return _Section(
      title: 'Lo que más usas',
      child: SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: top.length,
          itemBuilder: (_, i) => _UsageCard(usage: top[i]),
        ),
      ),
    );
  }
}

class _Forgotten extends StatelessWidget {
  const _Forgotten({required this.stats});

  final WardrobeStats stats;

  @override
  Widget build(BuildContext context) {
    final forgotten = stats.forgotten(limit: 8);
    if (forgotten.isEmpty) return const SizedBox.shrink();

    return _Section(
      title: 'Olvidadas',
      subtitle: 'Sin estrenar o sin usar hace más de dos meses',
      child: SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: forgotten.length,
          itemBuilder: (_, i) => _UsageCard(usage: forgotten[i]),
        ),
      ),
    );
  }
}

/// Desgaste: cuanto lleva lavada cada prenda y cuanto rinde por lavada.
class _Wear extends StatelessWidget {
  const _Wear({required this.stats});

  final WardrobeStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.totalWashes == 0) {
      return _Section(
        title: 'Desgaste',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            stats.neverWashedButWorn == 0
                ? 'Cuando registres lavadas veras cuanto aguanta cada prenda.'
                : 'Tienes ${stats.neverWashedButWorn} prendas usadas sin '
                    'ninguna lavada registrada. Apunta tus lavadas y la app '
                    'te dira cuanto le queda a cada una.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final washed = stats.mostWashed(limit: 8);
    final harsh = stats.hardestOnClothes(limit: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Section(
          title: 'Mas lavadas',
          subtitle: 'Lo que mas vueltas ha dado en la lavadora',
          child: SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: washed.length,
              itemBuilder: (_, i) => _WearCard(wear: washed[i]),
            ),
          ),
        ),
        if (harsh.isNotEmpty)
          _Section(
            title: 'Se gastan mas rapido',
            subtitle: 'Pocas puestas por lavada: van al agua casi cada uso',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final w in harsh)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: SizedBox(
                        width: 40,
                        height: 40,
                        child: GarmentImage(garment: w.garment),
                      ),
                      title: Text(w.garment.displayName),
                      subtitle: Text('${w.washCount} lavadas'),
                      trailing: Text(
                        w.wearsPerWash!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onTap: () => context.push('/garment/${w.garment.id}'),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _WearCard extends StatelessWidget {
  const _WearCard({required this.wear});

  final GarmentWear wear;

  @override
  Widget build(BuildContext context) {
    final g = wear.garment;
    final days = wear.daysSinceWashed;

    return SizedBox(
      width: 110,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => context.push('/garment/${g.id}'),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: GarmentImage(garment: g),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                  child: Column(
                    children: [
                      Text(
                        g.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${wear.washCount} lavadas'
                        '${days == null ? '' : ' - hace $days d'}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.usage});

  final GarmentUsage usage;

  @override
  Widget build(BuildContext context) {
    final g = usage.garment;
    final days = usage.daysSinceWorn;

    return SizedBox(
      width: 110,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => context.push('/garment/${g.id}'),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: GarmentImage(garment: g),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                  child: Column(
                    children: [
                      Text(
                        g.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        usage.neverWorn
                            ? 'sin estrenar'
                            : '${g.wearCount}x'
                                '${days == null ? '' : ' · hace $days d'}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorBreakdown extends StatelessWidget {
  const _ColorBreakdown({required this.stats});

  final WardrobeStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = stats.byColor(Labels.colorFamily);
    if (colors.isEmpty) return const SizedBox.shrink();
    final max = colors.first.count;

    return _Section(
      title: 'Tus colores',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            for (final b in colors)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    ColorDot(b.colorArgb ?? 0xFF808080, size: 16),
                    const SizedBox(width: 10),
                    SizedBox(width: 72, child: Text(b.label)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: b.count / max,
                          minHeight: 8,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text('${b.count}', textAlign: TextAlign.end),
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

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.stats});

  final WardrobeStats stats;

  @override
  Widget build(BuildContext context) {
    final cats = stats.byCategory();
    if (cats.isEmpty) return const SizedBox.shrink();

    return _Section(
      title: 'Qué tienes',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final b in cats)
              Chip(
                label: Text('${b.label}  ${b.count}'),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, subtitle == null ? 8 : 2),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(subtitle!,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        child,
      ],
    );
  }
}
