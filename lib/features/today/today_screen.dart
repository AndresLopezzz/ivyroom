import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/repos/garment_repository.dart' show ClosetFilter;
import '../../data/repos/plan_repository.dart';
import '../../data/weather/weather_repository.dart';
import '../../domain/models/garment.dart';
import '../../ui/design/components.dart';
import '../../ui/design/motion.dart';
import '../../ui/design/tokens.dart';
import '../../ui/design/type.dart';
import '../../ui/garment_image.dart';
import '../outfits/weather_sheet.dart';

const _weekdayLong = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];
const _weekdayTiny = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
const _monthLong = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// La pantalla de hoy.
///
/// Es la portada porque la pregunta de esta app se hace una vez al día y
/// siempre es la misma: qué me pongo. Todo lo demás —el catálogo, el
/// historial, el lavado— existe para que esta pantalla pueda responder bien.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = PlanRepository.dayKey(DateTime.now());

    return Stack(
      children: [
        const PaperGlow(),
        ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + Ivy.s3,
            bottom: 148,
          ),
          children: [
            const _TopRow(),
            const SizedBox(height: Ivy.s5),
            _Masthead(day: today),
            const SizedBox(height: Ivy.s5),
            const _WeekStrip(),
            const SizedBox(height: Ivy.s6),
            const _TodayOutfit(),
            const SizedBox(height: Ivy.s5),
            const _LaundryAnchor(),
            const SizedBox(height: Ivy.s4),
            const _ForgottenCard(),
            const _SharedClosetsCard(),
            const _QuickActions(),
          ],
        ),
      ],
    );
  }
}

/// Mayuscula inicial. Los nombres de dia y mes se guardan en minuscula
/// porque dentro de una frase van asi ("14 de marzo"); solo suben cuando
/// abren linea.
String _capital(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class _TopRow extends ConsumerWidget {
  const _TopRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Ivy.gutter),
      child: Row(
        children: [
          // El logotipo en minuscula, como la voz del resto de la app.
          Text('ivyroom', style: IvyType.label.copyWith(color: Ivy.ink)),
          const Spacer(),
          GlyphButton(
            icon: Icons.calendar_today_outlined,
            tooltip: 'Calendario',
            onTap: () => context.push('/calendar'),
          ),
          const SizedBox(width: Ivy.s2),
          GlyphButton(
            icon: Icons.insights_outlined,
            tooltip: 'Estadísticas',
            onTap: () => context.push('/stats'),
          ),
          const SizedBox(width: Ivy.s2),
          GlyphButton(
            icon: Icons.settings_outlined,
            tooltip: 'Ajustes',
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

/// La cabecera: el día en grande y el clima al lado.
class _Masthead extends ConsumerWidget {
  const _Masthead({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider).value ?? const WeatherState();
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 19
        ? 'Buenas tardes'
        : 'Buenas noches';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Ivy.gutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: IvyType.labelFaint),
                const SizedBox(height: Ivy.s2),
                // El día en Bricolage: es el momento con voz de la
                // pantalla, y el contraste de tamaño con todo lo demás es lo
                // que ordena la lectura.
                Text(
                  _capital(_weekdayLong[day.weekday - 1]),
                  style: IvyType.hero,
                ),
                Text(
                  '${day.day} de ${_monthLong[day.month - 1]}',
                  style: IvyType.body.copyWith(color: Ivy.inkSoft),
                ),
              ],
            ),
          ),
          _WeatherBadge(weather: weather),
        ],
      ),
    );
  }
}

class _WeatherBadge extends ConsumerWidget {
  const _WeatherBadge({required this.weather});

  final WeatherState weather;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = weather.weather;

    if (w == null || weather.mode == LocationMode.off) {
      return Pressable(
        onTap: () => _openWeather(context),
        child: Padding(
          padding: const EdgeInsets.only(bottom: Ivy.s2),
          child: Icon(Icons.wb_sunny_outlined, size: 22, color: Ivy.inkFaint),
        ),
      );
    }

    return Pressable(
      onTap: () => _openWeather(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: Ivy.s2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${w.tempC.round()}°', style: IvyType.numeral),
            Text(
              '${w.minC.round()}° / ${w.maxC.round()}°',
              style: IvyType.caption,
            ),
            if (w.rainChance >= 40)
              Text(
                'Lluvia ${w.rainChance}%',
                style: IvyType.caption.copyWith(color: Ivy.clay),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openWeather(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => const WeatherSheet(),
);

/// Tira de la semana con lo planificado en cada día.
class _WeekStrip extends ConsumerWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = PlanRepository.dayKey(DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final plans = ref.watch(weekStripProvider).value ?? const {};

    // Siete columnas flexibles y no una lista horizontal: la semana entra
    // completa en cualquier movil, y hoy nunca queda cortado en el borde.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Ivy.s4),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Builder(
                builder: (context) {
                  final day = monday.add(Duration(days: i));
                  final dayPlans = plans[day] ?? const <DayPlan>[];
                  final worn = dayPlans.where((p) => p.wasWorn).firstOrNull;
                  final shown = worn ?? dayPlans.firstOrNull;
                  final isToday = day == today;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Pressable(
                      onTap: () {
                        ref.read(selectedDayProvider.notifier).select(day);
                        context.push('/calendar');
                      },
                      child: AnimatedContainer(
                        duration: IvyMotion.fast,
                        height: 84,
                        padding: const EdgeInsets.symmetric(vertical: Ivy.s2),
                        decoration: BoxDecoration(
                          color: isToday ? Ivy.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(Ivy.rCard - 2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _weekdayTiny[i],
                              style: IvyType.caption.copyWith(
                                color: isToday ? Ivy.ink : Ivy.inkFaint,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${day.day}',
                              style: IvyType.smallStrong.copyWith(
                                color: isToday ? Ivy.ink : Ivy.inkSoft,
                              ),
                            ),
                            const SizedBox(height: Ivy.s1),
                            Expanded(
                              child: shown == null || shown.items.isEmpty
                                  ? const _EmptyDayMark()
                                  : _MiniStack(
                                      items: shown.items,
                                      faded: !isToday && worn == null,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Marca de un día sin nada planificado: una raya, no un hueco vacío.
class _EmptyDayMark extends StatelessWidget {
  const _EmptyDayMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 22,
        height: 3,
        decoration: BoxDecoration(
          color: Ivy.hairline,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Miniatura apilada de un outfit, del tamaño de una uña.
class _MiniStack extends StatelessWidget {
  const _MiniStack({required this.items, this.faded = false});

  final List<Garment> items;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.42 : 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final g in items.take(3))
            SizedBox(width: 15, child: GarmentImage(garment: g)),
        ],
      ),
    );
  }
}

/// El bloque principal: qué te pones hoy.
class _TodayOutfit extends ConsumerWidget {
  const _TodayOutfit();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = PlanRepository.dayKey(DateTime.now());
    final plans = ref.watch(todayPlansProvider).value ?? const [];
    final worn = plans.where((p) => p.wasWorn).firstOrNull;
    final planned = plans.where((p) => p.items.isNotEmpty).firstOrNull;
    final wardrobe = ref.watch(fullWardrobeProvider).value ?? const [];

    if (worn != null) {
      return _OutfitBlock(
        overline: 'Lo que llevas hoy',
        items: worn.items,
        footer: Row(
          children: [
            const Icon(Icons.check_circle, size: 18, color: Ivy.sage),
            const SizedBox(width: Ivy.s2),
            Text(
              'Registrado',
              style: IvyType.smallStrong.copyWith(color: Ivy.sage),
            ),
            const Spacer(),
            Pressable(
              onTap: () => ref.read(planRepositoryProvider).unmarkWorn(worn.id),
              child: Text(
                'Deshacer',
                style: IvyType.smallStrong.copyWith(color: Ivy.inkFaint),
              ),
            ),
          ],
        ),
      );
    }

    if (planned != null) {
      return _OutfitBlock(
        overline: 'Planificado para hoy',
        items: planned.items,
        footer: InkButton(
          label: 'Me lo puse',
          icon: Icons.check_rounded,
          onTap: () => ref.read(planRepositoryProvider).markWorn(planned.id),
        ),
      );
    }

    final suggestions = ref.watch(suggestionsForDayProvider(today));
    if (suggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Ivy.gutter),
        child: IvyCard(
          padding: const EdgeInsets.all(Ivy.s5),
          child: EmptyState(
            title: wardrobe.length < 3
                ? 'Tu armario aún es pequeño'
                : 'Nada que proponer',
            body: wardrobe.length < 3
                ? 'Necesitas algo de arriba, algo de abajo y un calzado para '
                      'que la app pueda montar conjuntos.'
                : 'Prueba a relajar los filtros en Outfits.',
            action: InkButton(
              label: 'Añadir prenda',
              icon: Icons.add_a_photo_outlined,
              expand: false,
              onTap: () => context.push('/capture'),
            ),
          ),
        ),
      );
    }

    final pick = suggestions.first;
    return _OutfitBlock(
      overline: 'Sugerencia de hoy',
      items: pick.items,
      reasons: pick.reasons,
      footer: Row(
        children: [
          Expanded(
            child: InkButton(
              label: 'Planificar',
              icon: Icons.event_available_outlined,
              onTap: () async {
                await ref
                    .read(planRepositoryProvider)
                    .addPlan(today, garments: pick.items);
              },
            ),
          ),
          const SizedBox(width: Ivy.s2),
          Pressable(
            onTap: ref.read(outfitRequestProvider.notifier).reroll,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Ivy.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh_rounded, color: Ivy.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutfitBlock extends StatelessWidget {
  const _OutfitBlock({
    required this.overline,
    required this.items,
    required this.footer,
    this.reasons,
  });

  final String overline;
  final List<Garment> items;
  final Widget footer;
  final List<String>? reasons;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Ivy.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(overline, style: IvyType.labelFaint),
          const SizedBox(height: Ivy.s3),
          IvyCard(
            padding: const EdgeInsets.fromLTRB(Ivy.s3, Ivy.s4, Ivy.s3, Ivy.s3),
            child: Column(
              children: [
                SizedBox(
                  height: 168,
                  child: Row(
                    children: [
                      for (final g in items)
                        Expanded(
                          child: Pressable(
                            onTap: () => context.push('/garment/${g.id}'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: GarmentImage(garment: g),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (reasons != null && reasons!.isNotEmpty) ...[
                  const SizedBox(height: Ivy.s3),
                  Text(
                    reasons!.take(2).join(' · '),
                    style: IvyType.caption,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: Ivy.s4),
                footer,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// La tarjeta negra: el ancla de contraste de la pantalla.
///
/// Solo aparece cuando hay algo que hacer. Una tarjeta negra que dice "0" no
/// ancla nada, solo grita.
class _LaundryAnchor extends ConsumerWidget {
  const _LaundryAnchor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirty = ref.watch(dirtyCountProvider);
    if (dirty == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Ivy.gutter),
      child: InkCard(
        onTap: () => context.go('/laundry'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$dirty',
                    style: IvyType.hero.copyWith(color: Ivy.surface),
                  ),
                  const SizedBox(height: Ivy.s1),
                  Text(
                    dirty == 1
                        ? 'Prenda usada sin lavar'
                        : 'Prendas usadas sin lavar',
                    style: IvyType.body.copyWith(
                      color: Ivy.surface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_outward_rounded, color: Ivy.surface),
          ],
        ),
      ),
    );
  }
}

/// Prendas que llevan tiempo sin salir del armario.
///
/// Se ofrece como sugerencia y no como reproche: lo util es acordarse de que
/// existen, y de paso ver que sobra.
class _ForgottenCard extends ConsumerWidget {
  const _ForgottenCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgotten = ref.watch(forgottenProvider);
    if (forgotten.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(Ivy.gutter, 0, Ivy.gutter, Ivy.s4),
      child: IvyCard(
        onTap: () {
          ref
              .read(closetFilterProvider.notifier)
              .set(const ClosetFilter(onlyForgotten: true));
          context.go('/closet');
        },
        padding: const EdgeInsets.all(Ivy.s4),
        child: Row(
          children: [
            SizedBox(
              height: 52,
              width: 52.0 + 18 * (forgotten.take(3).length - 1),
              child: Stack(
                children: [
                  for (final (i, g) in forgotten.take(3).indexed)
                    Positioned(
                      left: i * 18.0,
                      child: Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Ivy.paper,
                          borderRadius: BorderRadius.circular(Ivy.rThumb),
                          border: Border.all(color: Ivy.surface, width: 2),
                        ),
                        child: GarmentImage(garment: g),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Ivy.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    forgotten.length == 1
                        ? '1 prenda olvidada'
                        : '${forgotten.length} prendas olvidadas',
                    style: IvyType.bodyStrong,
                  ),
                  Text('Sin ponerse en más de dos meses',
                      style: IvyType.small),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Ivy.inkFaint),
          ],
        ),
      ),
    );
  }
}

/// Acceso a los armarios que otros comparten conmigo.
///
/// Va aqui y no solo en Ajustes: es la razon de que exista el visor, y
/// escondido tres pantallas mas abajo nadie lo encuentra.
class _SharedClosetsCard extends ConsumerWidget {
  const _SharedClosetsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shared = ref.watch(accountProvider).value?.shared ?? const [];
    if (shared.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final s in shared)
          Padding(
            padding:
                const EdgeInsets.fromLTRB(Ivy.gutter, 0, Ivy.gutter, Ivy.s4),
            child: IvyCard(
              onTap: () => context.push('/shared/${s.closetId}'),
              padding: const EdgeInsets.all(Ivy.s4),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Ivy.sageSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.checkroom_rounded,
                        color: Ivy.sage),
                  ),
                  const SizedBox(width: Ivy.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Armario de ${s.ownerName}',
                            style: IvyType.bodyStrong,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('Míralo y ármale un outfit',
                            style: IvyType.small),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Ivy.inkFaint),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Ivy.gutter),
      child: Row(
        children: [
          Expanded(
            child: _QuickAction(
              icon: Icons.add_a_photo_outlined,
              label: 'Añadir prenda',
              onTap: () => context.push('/capture'),
            ),
          ),
          const SizedBox(width: Ivy.s3),
          Expanded(
            child: _QuickAction(
              icon: Icons.dashboard_customize_outlined,
              label: 'Armar outfit',
              onTap: () {
                ref.read(outfitBuilderProvider.notifier).clear();
                ref.read(builderTargetDayProvider.notifier).select(null);
                context.push('/build-outfit');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IvyCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: Ivy.s4, vertical: Ivy.s4),
      child: Row(
        children: [
          Icon(icon, size: 19, color: Ivy.ink),
          const SizedBox(width: Ivy.s3),
          Expanded(
            child: Text(
              label,
              style: IvyType.smallStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
