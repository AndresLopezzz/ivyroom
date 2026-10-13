import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../share/outfit_share.dart';
import '../../data/repos/plan_repository.dart';
import '../../data/weather/weather_repository.dart';
import '../../domain/models/catalog.dart';
import '../../domain/models/outfit.dart';
import '../../ui/design/components.dart';
import '../../ui/design/motion.dart';
import '../../ui/design/sentence_filters.dart';
import '../../ui/design/tokens.dart';
import '../../ui/design/type.dart';
import '../../ui/garment_image.dart';
import '../../ui/labels.dart';
import 'weather_sheet.dart';

class OutfitsScreen extends ConsumerWidget {
  const OutfitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobe = ref.watch(fullWardrobeProvider).value ?? const [];
    final suggestions = ref.watch(outfitSuggestionsProvider);
    final top = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        if (suggestions.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: top + 120),
            child: _Empty(wardrobeSize: wardrobe.length),
          )
        else
          ListView.builder(
            padding: EdgeInsets.only(top: top + 118, bottom: 140),
            itemCount: suggestions.length,
            itemBuilder: (_, i) => _SuggestionCard(suggestion: suggestions[i]),
          ),
        const _Chrome(),
      ],
    );
  }
}

class _Chrome extends ConsumerWidget {
  const _Chrome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        GlassBar(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + Ivy.s2,
            left: Ivy.gutter,
            right: Ivy.s3,
            bottom: Ivy.s1,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: Ivy.gutter, right: Ivy.s3),
                child: Row(
                children: [
                  Text('Outfits', style: IvyType.title),
                  const Spacer(),
                  GlyphButton(
                    filled: false,
                    icon: Icons.bookmark_border_rounded,
                    tooltip: 'Guardados',
                    onTap: () => context.push('/saved'),
                  ),
                  GlyphButton(
                    filled: false,
                    icon: Icons.dashboard_customize_outlined,
                    tooltip: 'Armar a mano',
                    onTap: () {
                      ref.read(outfitBuilderProvider.notifier).clear();
                      ref.read(builderTargetDayProvider.notifier).select(null);
                      context.push('/build-outfit');
                    },
                  ),
                  GlyphButton(
                    filled: false,
                    icon: Icons.refresh_rounded,
                    tooltip: 'Otras combinaciones',
                    onTap: ref.read(outfitRequestProvider.notifier).reroll,
                  ),
                ],
              )),
              const SizedBox(height: Ivy.s1),
              const _RequestSentence(),
            ],
          ),
        ),
        const ScrollEdge(),
      ],
    );
  }
}

/// Los criterios escritos como una frase en vez de una fila de chips sueltos.
///
/// La diferencia no es decorativa: leyendo *"para trabajo, con mood elegante,
/// a 18°"* se entiende de un golpe qué está pidiendo el motor y qué huecos
/// quedan sin decidir. Una fila de chips iguales no dice ninguna de las dos
/// cosas.
class _RequestSentence extends ConsumerWidget {
  const _RequestSentence();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final req = ref.watch(outfitRequestProvider);
    final notifier = ref.read(outfitRequestProvider.notifier);
    final occs = ref.watch(occasionsProvider).value ?? const <Occasion>[];
    final moods = ref.watch(moodsProvider).value ?? const <Mood>[];
    final weather = ref.watch(weatherProvider).value ?? const WeatherState();
    final autoTemp = ref.watch(todayTempProvider);

    return SentenceFilters(
      padding: const EdgeInsets.symmetric(horizontal: Ivy.gutter),
      parts: [
        'para',
        FilterSlot(
          value: req.occasion?.name,
          placeholder: 'ocasión',
          onTap: () async {
            final picked = await _pick<Occasion>(
                context, 'Ocasión', occs, (o) => o.name, req.occasion);
            notifier.set(picked == null
                ? req.copyWith(clearOccasion: true)
                : req.copyWith(occasion: picked));
          },
        ),
        'con',
        FilterSlot(
          value: req.mood?.name,
          placeholder: 'mood',
          onTap: () async {
            final picked =
                await _pick<Mood>(context, 'Mood', moods, (m) => m.name, req.mood);
            notifier.set(picked == null
                ? req.copyWith(clearMood: true)
                : req.copyWith(mood: picked));
          },
        ),
        'en',
        FilterSlot(
          value: req.season == null ? null : Labels.season(req.season!),
          placeholder: 'temporada',
          onTap: () async {
            final picked = await _pick<Season>(context, 'Temporada',
                Season.values, Labels.season, req.season);
            notifier.set(picked == null
                ? req.copyWith(clearSeason: true)
                : req.copyWith(season: picked));
          },
        ),
        'a',
        FilterSlot(
          icon: weather.mode == LocationMode.off
              ? Icons.thermostat_rounded
              : Icons.wb_sunny_outlined,
          value: autoTemp != null
              ? '${autoTemp.round()}°'
              : req.tempC != null
                  ? '${req.tempC!.round()}°'
                  : null,
          placeholder: 'clima',
          onTap: () async {
            // Con el clima automático puesto, el hueco abre su configuración:
            // dos sitios donde editar la misma temperatura solo confunden.
            if (weather.mode != LocationMode.off) {
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const WeatherSheet(),
              );
              return;
            }
            final t = await _askTemperature(context, req.tempC);
            if (t == null) return;
            notifier.set(t.isNaN
                ? req.copyWith(clearTemp: true)
                : req.copyWith(tempC: t));
          },
        ),
      ],
    );
  }
}

/// Marca de "quitar el filtro".
///
/// Hace falta porque cerrar la hoja sin elegir también devuelve null, y hay
/// que distinguir "no toques nada" de "quítalo".
final _clear = Object();

Future<T?> _pick<T>(
  BuildContext context,
  String title,
  List<T> values,
  String Function(T) label,
  T? current,
) async {
  final result = await showModalBottomSheet<Object>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Ivy.gutter, 0, Ivy.gutter, Ivy.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: IvyType.title),
            const SizedBox(height: Ivy.s4),
            Wrap(
              spacing: Ivy.s2,
              runSpacing: Ivy.s2,
              children: [
                Pill(
                  label: 'Cualquiera',
                  selected: current == null,
                  tone: PillTone.onSurface,
                  onTap: () => Navigator.pop(ctx, _clear),
                ),
                for (final v in values)
                  Pill(
                    label: label(v),
                    selected: v == current,
                    tone: PillTone.onSurface,
                    onTap: () => Navigator.pop(ctx, v as Object),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (result == null) return current;
  if (identical(result, _clear)) return null;
  return result as T;
}

Future<double?> _askTemperature(BuildContext context, double? current) {
  var value = current ?? 18;
  return showModalBottomSheet<double>(
    context: context,
    builder: (ctx) => SafeArea(
      child: StatefulBuilder(
        builder: (_, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(Ivy.gutter, 0, Ivy.gutter, Ivy.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Temperatura', style: IvyType.title),
              const SizedBox(height: Ivy.s3),
              Center(child: Text('${value.round()}°', style: IvyType.hero)),
              Slider(
                value: value,
                min: -10,
                max: 40,
                divisions: 50,
                onChanged: (v) => setLocal(() => value = v),
              ),
              const SizedBox(height: Ivy.s3),
              Row(
                children: [
                  Expanded(
                    child: InkButton(
                      label: 'Sin filtro',
                      tone: InkButtonTone.paper,
                      onTap: () => Navigator.pop(ctx, double.nan),
                    ),
                  ),
                  const SizedBox(width: Ivy.s3),
                  Expanded(
                    child: InkButton(
                      label: 'Aplicar',
                      onTap: () => Navigator.pop(ctx, value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SuggestionCard extends ConsumerWidget {
  const _SuggestionCard({required this.suggestion});

  final OutfitSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = PlanRepository.dayKey(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(Ivy.gutter, 0, Ivy.gutter, Ivy.s3),
      child: IvyCard(
        padding: const EdgeInsets.fromLTRB(Ivy.s3, Ivy.s4, Ivy.s3, Ivy.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 148,
              child: Row(
                children: [
                  for (final g in suggestion.items)
                    Expanded(
                      child: Pressable(
                        onTap: () => context.push('/garment/${g.id}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GarmentImage(garment: g),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Ivy.s3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Ivy.s2),
              child: Text(
                // Las razones son el contrato del motor con quien lo usa: sin
                // ellas una sugerencia es solo un número opaco.
                suggestion.reasons.join(' · '),
                style: IvyType.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: Ivy.s3),
            Row(
              children: [
                const SizedBox(width: Ivy.s2),
                Text('${(suggestion.score * 100).round()}%',
                    style: IvyType.smallStrong.copyWith(color: Ivy.inkFaint)),
                const Spacer(),
                Pressable(
                  onTap: () => shareOutfit(context, ref, suggestion.items),
                  child: const Padding(
                    padding: EdgeInsets.all(Ivy.s2),
                    child: Icon(Icons.ios_share_rounded,
                        size: 20, color: Ivy.inkSoft),
                  ),
                ),
                Pressable(
                  onTap: () async {
                    final req = ref.read(outfitRequestProvider);
                    await ref.read(outfitRepositoryProvider).save(
                          suggestion.items,
                          occasion: req.occasion,
                          mood: req.mood,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Outfit guardado')),
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(Ivy.s2),
                    child: Icon(Icons.bookmark_add_outlined,
                        size: 20, color: Ivy.inkSoft),
                  ),
                ),
                const SizedBox(width: Ivy.s2),
                Pressable(
                  onTap: () async {
                    await ref
                        .read(planRepositoryProvider)
                        .addPlan(today, garments: suggestion.items);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Planificado para hoy')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Ivy.s4, vertical: Ivy.s2 + 2),
                    decoration: BoxDecoration(
                      color: Ivy.ink,
                      borderRadius: BorderRadius.circular(Ivy.rPill),
                    ),
                    child: Text('Ponérmelo hoy',
                        style:
                            IvyType.smallStrong.copyWith(color: Ivy.surface)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.wardrobeSize});

  final int wardrobeSize;

  @override
  Widget build(BuildContext context) {
    // Se distingue "armario corto" de "filtros demasiado estrechos": el
    // remedio es distinto en cada caso.
    final needsClothes = wardrobeSize < 3;
    return EmptyState(
      title: needsClothes ? 'Faltan prendas' : 'Nada encaja',
      body: needsClothes
          ? 'Necesitas algo de arriba, algo de abajo y un calzado para poder '
              'montar conjuntos.'
          : 'Ninguna combinación cumple estos criterios. Prueba a relajar la '
              'ocasión o el clima.',
      action: needsClothes
          ? InkButton(
              label: 'Añadir prenda',
              icon: Icons.add_a_photo_outlined,
              expand: false,
              onTap: () => context.push('/capture'),
            )
          : null,
    );
  }
}
