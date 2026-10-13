import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/config.dart';
import '../../app/providers.dart';
import '../../ui/design/components.dart';
import '../../ui/design/tokens.dart';
import '../../ui/design/type.dart';

/// Frase de la primera pantalla. Se personaliza con `WELCOME_MESSAGE` en
/// `config.json`, sin tocar el codigo.
const onboardingDedication = AppConfig.welcomeMessage;

class _Page {
  const _Page(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const _pages = [
  _Page(
    Icons.checkroom_rounded,
    'Tu armario, en el bolsillo',
    onboardingDedication,
  ),
  _Page(
    Icons.add_a_photo_outlined,
    'Fotografía tu ropa',
    'La app quita el fondo sola. Con mucha ropa, elige varias fotos de la '
        'galería a la vez y solo tendrás que decir qué es cada una.',
  ),
  _Page(
    Icons.auto_awesome_outlined,
    'Outfits que combinan',
    'Te propone conjuntos según el color, la ocasión y el clima de hoy, y '
        'evita repetirte. Guarda los que te gusten y compártelos.',
  ),
  _Page(
    Icons.calendar_month_outlined,
    'Tu diario de looks',
    'Planifica la semana, marca lo que te pusiste y añade la foto del '
        'espejo. Con el tiempo, el calendario se vuelve un álbum.',
  ),
  _Page(
    Icons.local_laundry_service_outlined,
    'Sabe qué está por lavar',
    'Lo que te pones se marca solo como usado, y la pestaña Lavado te dice '
        'qué va a la lavadora.',
  ),
];

/// La bienvenida. Solo se ve una vez; luego queda marcada en las
/// preferencias.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<OnboardingScreen> {
  final _pager = PageController();
  var _index = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  bool get _last => _index == _pages.length;

  Future<void> _done(String route) async {
    await ref
        .read(appPrefsProvider.notifier)
        .change((p) => p.copyWith(onboarded: true));
    if (!mounted) return;
    context.go('/today');
    if (route != '/today') context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ivy.paper,
      body: Stack(
        children: [
          const PaperGlow(),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    opacity: _last ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: _last ? null : () => _done('/today'),
                      child: const Text('Saltar'),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pager,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: [
                      for (final p in _pages) _PageView(page: p),
                      const _StartPage(),
                    ],
                  ),
                ),
                _Dots(count: _pages.length + 1, index: _index),
                Padding(
                  padding: const EdgeInsets.all(Ivy.gutter),
                  child: _last
                      ? Column(
                          children: [
                            InkButton(
                              label: 'Añadir mis primeras prendas',
                              icon: Icons.collections_outlined,
                              onTap: () => _done('/capture-batch'),
                            ),
                            const SizedBox(height: Ivy.s3),
                            InkButton(
                              label: 'Explorar primero',
                              tone: InkButtonTone.paper,
                              onTap: () => _done('/today'),
                            ),
                          ],
                        )
                      : InkButton(
                          label: 'Siguiente',
                          onTap: () => _pager.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page});

  final _Page page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Ivy.s6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Ivy.sageSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 52, color: Ivy.sage),
          ),
          const SizedBox(height: Ivy.s6),
          Text(page.title,
              style: IvyType.display, textAlign: TextAlign.center),
          const SizedBox(height: Ivy.s4),
          Text(page.body,
              style: IvyType.body.copyWith(color: Ivy.inkSoft),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Ultima pagina: ofrece el aviso diario antes de empezar, que es cuando
/// tiene sentido preguntar por el permiso.
class _StartPage extends ConsumerWidget {
  const _StartPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled =
        ref.watch(appPrefsProvider).value?.reminderEnabled ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Ivy.s6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('¿Empezamos?',
              style: IvyType.display, textAlign: TextAlign.center),
          const SizedBox(height: Ivy.s4),
          Text(
            'Si quieres, cada mañana te aviso con qué ponerte.',
            style: IvyType.body.copyWith(color: Ivy.inkSoft),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Ivy.s5),
          IvyCard(
            padding: const EdgeInsets.symmetric(
                horizontal: Ivy.s4, vertical: Ivy.s2),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Aviso por la mañana', style: IvyType.bodyStrong),
              subtitle: Text('Puedes cambiar la hora en Ajustes',
                  style: IvyType.small),
              value: enabled,
              onChanged: (on) async {
                if (on &&
                    !await ref.read(dailyReminderProvider).requestPermission()) {
                  return;
                }
                await ref
                    .read(appPrefsProvider.notifier)
                    .change((p) => p.copyWith(reminderEnabled: on));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? Ivy.ink : Ivy.hairline,
              borderRadius: BorderRadius.circular(Ivy.rPill),
            ),
          ),
      ],
    );
  }
}
