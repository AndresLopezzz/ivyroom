import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/weather/weather_repository.dart';
import '../../data/weather/weather_service.dart';

/// Configura de dónde sale la temperatura que usa el generador de outfits.
class WeatherSheet extends ConsumerStatefulWidget {
  const WeatherSheet({super.key});

  @override
  ConsumerState<WeatherSheet> createState() => _WeatherSheetState();
}

class _WeatherSheetState extends ConsumerState<WeatherSheet> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<Place> _results = const [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQuery(String value) {
    // Se espera a que deje de escribir: sin esto cada letra sería una
    // petición a un servicio público y gratuito, que no está bien.
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() => _results = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _searching = true);
      try {
        final found =
            await ref.read(weatherProvider.notifier).search(value);
        if (mounted) setState(() => _results = found);
      } on WeatherException {
        if (mounted) setState(() => _results = const []);
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider).value ?? const WeatherState();
    final notifier = ref.read(weatherProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clima', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Con el clima puesto, la app propone abrigo según lo que vaya '
                'a hacer hoy de verdad.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),

              if (state.weather != null) _Current(state: state),
              if (state.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error),
                ),
              ],

              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: state.loading
                    ? null
                    : () async {
                        await notifier.useCurrentLocation();
                      },
                icon: const Icon(Icons.my_location),
                label: const Text('Usar mi ubicación'),
              ),
              const SizedBox(height: 16),

              Text('O busca tu ciudad',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _search,
                onChanged: _onQuery,
                decoration: InputDecoration(
                  hintText: 'Medellín, Bogotá, Cali...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
              ),
              for (final place in _results)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(place.label),
                  onTap: () async {
                    _search.clear();
                    setState(() => _results = const []);
                    await notifier.usePlace(place);
                  },
                ),

              if (state.mode != LocationMode.off) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: notifier.turnOff,
                  icon: const Icon(Icons.close),
                  label: const Text('Quitar el clima y poner la temperatura '
                      'a mano'),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Listo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Current extends StatelessWidget {
  const _Current({required this.state});

  final WeatherState state;

  @override
  Widget build(BuildContext context) {
    final w = state.weather!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${w.tempC.round()}°',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w.place ?? state.place?.name ?? 'Tu ubicación',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('mín ${w.minC.round()}°  ·  máx ${w.maxC.round()}°'
                        '  ·  lluvia ${w.rainChance}%'),
                  ],
                ),
              ),
              if (state.loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Para vestirte se usan ${w.dressingTempC.round()}°, que pondera '
            'la mínima del día: si sales de día y vuelves de noche, el '
            'termómetro de ahora te dejaría sin abrigo.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
