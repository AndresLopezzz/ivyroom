import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/repos/plan_repository.dart';
import '../../ui/garment_image.dart';
import 'look_photo.dart';
import 'week_planner.dart';

const _dayLetters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
const _monthNames = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];
const _weekdayNames = [
  'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
];

/// Qué ponerse cada día.
///
/// Un día admite varias opciones y al llegar se marca cuál se llevó: eso es
/// lo que separa planificar (barajar) de registrar (lo que pasó), y es lo
/// que alimenta la memoria del motor para no repetirse.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final selected = ref.watch(selectedDayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          TextButton.icon(
            onPressed: () => _planWeek(context, ref),
            icon: const Icon(Icons.auto_awesome_motion_outlined, size: 18),
            label: const Text('La semana'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _MonthGrid(month: month, selected: selected),
          const Divider(height: 24),
          _SelectedDay(day: selected),
        ],
      ),
    );
  }
}

/// Rejilla del mes con los días que tienen algo marcado.
class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({required this.month, required this.selected});

  final DateTime month;
  final DateTime selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final plans = ref.watch(monthPlansProvider).value ?? const {};
    final laundry = ref.watch(monthLaundryProvider).value ?? const <DateTime>{};
    final today = PlanRepository.dayKey(DateTime.now());

    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // `weekday` va de 1 (lunes) a 7 (domingo); la rejilla empieza en lunes.
    final leading = first.weekday - 1;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () =>
                      ref.read(calendarMonthProvider.notifier).shift(-1),
                ),
                Expanded(
                  child: Text(
                    '${_monthNames[month.month - 1]} ${month.year}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () =>
                      ref.read(calendarMonthProvider.notifier).shift(1),
                ),
              ],
            ),
            Row(
              children: [
                for (final letter in _dayLetters)
                  Expanded(
                    child: Center(
                      child: Text(
                        letter,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: scheme.outline),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (var row = 0; row * 7 < leading + daysInMonth; row++)
              Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: _buildCell(
                        context,
                        ref,
                        row * 7 + col - leading + 1,
                        daysInMonth,
                        plans,
                        laundry,
                        today,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    WidgetRef ref,
    int dayNumber,
    int daysInMonth,
    Map<DateTime, List<DayPlan>> plans,
    Set<DateTime> laundry,
    DateTime today,
  ) {
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox(height: 44);
    }

    final scheme = Theme.of(context).colorScheme;
    final date = DateTime(month.year, month.month, dayNumber);
    final dayPlans = plans[date] ?? const <DayPlan>[];
    final worn = dayPlans.any((p) => p.wasWorn);
    final photo = dayPlans
        .where((p) => p.wasWorn && p.photoPath != null)
        .map((p) => p.photoPath!)
        .firstOrNull;
    final storage = ref.watch(imageStorageProvider).value;
    final isSelected = date == selected;
    final isToday = date == today;

    return InkWell(
      onTap: () => ref.read(selectedDayProvider.notifier).select(date),
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 44,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Relleno = lo que ya se llevó puesto; borde = solo planificado.
              color: isSelected
                  ? scheme.primary
                  : worn
                      ? scheme.primaryContainer
                      : null,
              border: !isSelected && !worn && dayPlans.isNotEmpty
                  ? Border.all(color: scheme.primary)
                  : isSelected && photo != null
                      ? Border.all(color: scheme.primary, width: 3)
                      : null,
              // El dia con foto se ve como el recuerdo que es, no como un
              // numero coloreado: el mes se lee como un album.
              image: photo == null || storage == null
                  ? null
                  : DecorationImage(
                      image: ResizeImage(FileImage(storage.fileFor(photo)),
                          width: 108),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.25),
                          BlendMode.darken),
                    ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    color: photo != null
                        ? Colors.white
                        : isSelected
                        ? scheme.onPrimary
                        : isToday
                            ? scheme.primary
                            : null,
                    fontWeight: isToday ? FontWeight.bold : null,
                  ),
                ),
                if (laundry.contains(date))
                  Positioned(
                    bottom: 1,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? scheme.onPrimary : scheme.tertiary,
                        shape: BoxShape.circle,
                      ),
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

/// El día elegido, con sus opciones.
class _SelectedDay extends ConsumerWidget {
  const _SelectedDay({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(selectedDayPlansProvider).value ?? const [];
    final today = PlanRepository.dayKey(DateTime.now());
    final isPast = day.isBefore(today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(
            children: [
              Text(
                '${_weekdayNames[day.weekday - 1]} ${day.day}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              if (day == today)
                Chip(
                  label: const Text('hoy'),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
        if (plans.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              isPast
                  ? 'No registraste nada este día.'
                  : 'Sin planes todavía.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          for (final plan in plans)
            _PlanRow(plan: plan, isPast: isPast),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextButton.icon(
            onPressed: () => _pickForDay(context, ref, day),
            icon: const Icon(Icons.add, size: 18),
            // El texto cambia con el tiempo verbal: para atrás se registra
            // lo que pasó, para adelante se planifica lo que se piensa hacer.
            label: Text(isPast ? 'Registrar lo que usé' : 'Planificar outfit'),
          ),
        ),
      ],
    );
  }
}

class _PlanRow extends ConsumerWidget {
  const _PlanRow({required this.plan, required this.isPast});

  final DayPlan plan;
  final bool isPast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.read(planRepositoryProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: plan.wasWorn ? scheme.primary : scheme.outlineVariant,
          width: plan.wasWorn ? 2 : 1,
        ),
        color: plan.wasWorn ? scheme.primaryContainer.withValues(alpha: 0.3)
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: plan.items.isEmpty
                ? Text('El outfit ya no existe',
                    style: Theme.of(context).textTheme.bodySmall)
                : SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final g in plan.items)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: GestureDetector(
                              onTap: () => context.push('/garment/${g.id}'),
                              child: SizedBox(
                                  width: 40, child: GarmentImage(garment: g)),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          if (plan.items.isNotEmpty)
            TextButton(
              onPressed: () => plan.wasWorn
                  ? repo.unmarkWorn(plan.id)
                  : repo.markWorn(plan.id),
              child: Text(
                plan.wasWorn ? 'Lo usé' : '¿Lo usaste?',
                style: TextStyle(
                  color: plan.wasWorn ? scheme.primary : scheme.outline,
                ),
              ),
            ),
          if (plan.wasWorn) _LookThumb(plan: plan),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close, size: 18),
            onPressed: () async {
              await repo.removePlan(plan.id);
              // La foto se va con el plan: si no, queda huerfana en disco.
              if (plan.photoPath != null) {
                final storage = await ref.read(imageStorageProvider.future);
                await storage.deleteAll([plan.photoPath]);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// La foto del look de un plan puesto, o el boton para anadirla.
class _LookThumb extends ConsumerWidget {
  const _LookThumb({required this.plan});

  final DayPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(imageStorageProvider).value;
    final path = plan.photoPath;
    if (path == null || storage == null) {
      return IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: 'Añadir foto del look',
        icon: const Icon(Icons.add_a_photo_outlined, size: 20),
        onPressed: () => addLookPhoto(context, ref, plan),
      );
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => LookPhotoViewer(plan: plan),
      )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          storage.fileFor(path),
          width: 40,
          height: 48,
          fit: BoxFit.cover,
          cacheWidth: 120,
        ),
      ),
    );
  }
}

// ---- elegir un outfit para un dia ------------------------------------------

Future<void> _pickForDay(
    BuildContext context, WidgetRef ref, DateTime day) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PlanPicker(day: day),
  );
}

class _PlanPicker extends ConsumerWidget {
  const _PlanPicker({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedOutfitsProvider).value ?? const [];
    // Las sugerencias se piden PARA ese día: así el motor tiene en cuenta su
    // día de la semana y no propone lo que ya llevaste ese mismo día.
    final suggestions = ref.watch(suggestionsForDayProvider(day));
    final repo = ref.read(planRepositoryProvider);

    Future<void> close() async {
      if (context.mounted) Navigator.pop(context);
    }

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text('${_weekdayNames[day.weekday - 1]} ${day.day}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.pop(context);
                ref.read(outfitBuilderProvider.notifier).clear();
                ref.read(builderTargetDayProvider.notifier).select(day);
                context.push('/build-outfit');
              },
              icon: const Icon(Icons.dashboard_customize_outlined),
              label: const Text('Armar uno a mano'),
            ),
            if (saved.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Guardados',
                  style: Theme.of(context).textTheme.labelLarge),
              for (final o in saved)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(o.displayName),
                  subtitle: Text('${o.items.length} prendas'),
                  leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: o.items.isEmpty
                        ? const Icon(Icons.checkroom)
                        : GarmentImage(garment: o.items.first),
                  ),
                  trailing: o.isFavorite
                      ? const Icon(Icons.favorite, size: 16, color: Colors.red)
                      : null,
                  onTap: () async {
                    await repo.addPlan(day, outfit: o);
                    await close();
                  },
                ),
            ],
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Sugerencias',
                  style: Theme.of(context).textTheme.labelLarge),
              for (final s in suggestions.take(5))
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      await repo.addPlan(day, garments: s.items);
                      await close();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 80,
                            child: Row(
                              children: [
                                for (final g in s.items)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: GarmentImage(garment: g),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.reasons.join(' · '),
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            if (saved.isEmpty && suggestions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Todavía no hay outfits guardados ni sugerencias. Añade '
                  'más prendas o arma uno a mano.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---- planificar la semana --------------------------------------------------

/// Propone un outfit distinto para cada día de una semana.
///
/// Se genera día a día y arrastrando lo ya elegido al historial, para que el
/// martes no repita lo del lunes: sin eso, la misma combinación ganadora
/// saldría los cinco días.
Future<void> _planWeek(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const WeekPlanner(),
  );
}
