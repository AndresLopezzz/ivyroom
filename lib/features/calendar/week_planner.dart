import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/repos/plan_repository.dart';
import '../../domain/models/outfit.dart';
import '../../domain/outfit/wear_history.dart';
import '../../ui/design/components.dart';
import '../../ui/design/tokens.dart';
import '../../ui/garment_image.dart';

const _weekdayShort = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

/// Organiza varios días de golpe.
///
/// Es el caso de uso que hace útil planificar: el domingo por la noche dejas
/// resuelta la semana. Se propone un conjunto distinto por día porque
/// generar cada día por separado daría cinco veces el mismo ganador.
class WeekPlanner extends ConsumerStatefulWidget {
  const WeekPlanner({super.key});

  @override
  ConsumerState<WeekPlanner> createState() => _WeekPlannerState();
}

class _WeekPlannerState extends ConsumerState<WeekPlanner> {
  /// Solo de lunes a viernes por defecto: el fin de semana la gente
  /// improvisa, y proponerlo sería ruido.
  bool _weekendToo = false;
  int _weekOffset = 1;
  int _seed = 0;

  Map<DateTime, OutfitSuggestion>? _proposal;
  bool _busy = false;

  DateTime get _monday {
    final today = PlanRepository.dayKey(DateTime.now());
    final thisMonday =
        today.subtract(Duration(days: today.weekday - DateTime.monday));
    return thisMonday.add(Duration(days: 7 * _weekOffset));
  }

  List<DateTime> get _days => [
        for (var i = 0; i < (_weekendToo ? 7 : 5); i++)
          _monday.add(Duration(days: i)),
      ];

  @override
  void initState() {
    super.initState();
    // Se propone al abrir: llegar a una pantalla vacía con un botón
    // "generar" es un paso de más cuando solo hay una cosa que hacer.
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  /// Genera un conjunto por día arrastrando lo ya elegido al historial.
  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      final wardrobe = ref.read(fullWardrobeProvider).value ?? const [];
      final engine = ref.read(outfitEngineProvider);
      final base = ref.read(effectiveOutfitRequestProvider);
      final history =
          await ref.read(planRepositoryProvider).wearHistory();

      final chosen = <DateTime, OutfitSuggestion>{};
      // Copia viva del historial: cada día elegido entra en ella, así el
      // siguiente ya sabe que no debe repetirlo.
      final entries = [...history.entries];

      for (final day in _days) {
        final suggestions = engine.generate(
          wardrobe,
          base.copyWith(forDay: day, count: 1, seed: _seed + day.day),
          history: WearHistory(entries),
        );
        if (suggestions.isEmpty) continue;

        final pick = suggestions.first;
        chosen[day] = pick;
        entries.add(WearEntry(
          day: day,
          garmentIds: pick.items.map((g) => g.id).toSet(),
        ));
      }

      if (mounted) setState(() => _proposal = chosen);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final proposal = _proposal;
    if (proposal == null || proposal.isEmpty) return;

    await ref.read(planRepositoryProvider).planDays({
      for (final e in proposal.entries) e.key: e.value.items,
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Planificados ${proposal.length} días')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final proposal = _proposal ?? const <DateTime, OutfitSuggestion>{};

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Planificar la semana',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Un conjunto distinto para cada día, sin repetir lo que '
                    'ya llevaste.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Pill(
                          label: 'Esta semana',
                          dense: true,
                          selected: _weekOffset == 0,
                          tone: PillTone.onSurface,
                          onTap: () {
                            setState(() => _weekOffset = 0);
                            _generate();
                          },
                        ),
                        const SizedBox(width: Ivy.s2),
                        Pill(
                          label: 'La que viene',
                          dense: true,
                          selected: _weekOffset == 1,
                          tone: PillTone.onSurface,
                          onTap: () {
                            setState(() => _weekOffset = 1);
                            _generate();
                          },
                        ),
                        const SizedBox(width: Ivy.s2),
                        Pill(
                          label: 'Con fin de semana',
                          dense: true,
                          selected: _weekendToo,
                          tone: PillTone.onSurface,
                          onTap: () {
                            setState(() => _weekendToo = !_weekendToo);
                            _generate();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _busy
                  ? const Center(child: CircularProgressIndicator())
                  : proposal.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No se pudo montar ningún conjunto. Te falta '
                              'ropa de alguna categoría.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        )
                      : ListView(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            for (final day in _days)
                              _DayProposal(
                                day: day,
                                suggestion: proposal[day],
                              ),
                          ],
                        ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _busy
                        ? null
                        : () {
                            setState(() => _seed++);
                            _generate();
                          },
                    icon: const Icon(Icons.casino_outlined),
                    label: const Text('Otra propuesta'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: proposal.isEmpty || _busy ? null : _save,
                    child: Text('Planificar ${proposal.length} días'),
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

class _DayProposal extends StatelessWidget {
  const _DayProposal({required this.day, required this.suggestion});

  final DateTime day;
  final OutfitSuggestion? suggestion;

  @override
  Widget build(BuildContext context) {
    final s = suggestion;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(_weekdayShort[day.weekday - 1],
                      style: Theme.of(context).textTheme.labelSmall),
                  Text('${day.day}',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            Expanded(
              child: s == null
                  ? Text('Sin propuesta',
                      style: Theme.of(context).textTheme.bodySmall)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 64,
                          child: Row(
                            children: [
                              for (final g in s.items)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: SizedBox(
                                    width: 48,
                                    child: GarmentImage(garment: g),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.reasons.join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
            if (s != null)
              Text('${(s.score * 100).round()}%',
                  style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
