import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';

/// Correos invitados a ver mi armario.
final invitesProvider =
    FutureProvider.autoDispose<List<({String id, String email})>>((ref) async {
  final session = ref.watch(accountProvider).value;
  if (session == null) return const [];
  final rows = await ref.read(convexProvider).query('invites:list') as List;
  return [
    for (final r in rows.cast<Map>())
      (id: r['id'] as String, email: r['email'] as String),
  ];
});

/// Cuenta de Google, copia en la nube y con quien se comparte el armario.
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Cuenta y compartir',
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: theme.colorScheme.primary)),
        ),
        account.when(
          loading: () => const ListTile(
            leading: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2)),
            title: Text('Conectando…'),
          ),
          error: (e, _) => Column(
            children: [
              ListTile(
                leading: const Icon(Icons.error_outline),
                title: const Text('No se pudo iniciar sesión'),
                subtitle: Text('$e'),
              ),
              _SignInTile(),
            ],
          ),
          data: (session) =>
              session == null ? _SignInTile() : _SignedIn(session: session),
        ),
      ],
    );
  }
}

class _SignInTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.account_circle_outlined),
      title: const Text('Iniciar sesión con Google'),
      subtitle: const Text(
          'Guarda una copia del armario en la nube y compártelo con quien '
          'quieras'),
      onTap: () => ref.read(accountProvider.notifier).signIn(),
    );
  }
}

class _SignedIn extends ConsumerWidget {
  const _SignedIn({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncProvider);
    final invites = ref.watch(invitesProvider);
    final last = sync.lastAt ?? session.lastSyncAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage:
                session.photoUrl == null ? null : NetworkImage(session.photoUrl!),
            child: session.photoUrl == null
                ? const Icon(Icons.person_outline)
                : null,
          ),
          title: Text(session.name ?? session.email),
          subtitle: Text(session.email),
          trailing: TextButton(
            onPressed: () => ref.read(accountProvider.notifier).signOut(),
            child: const Text('Salir'),
          ),
        ),
        ListTile(
          leading: sync.running
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(sync.error == null
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_off_outlined),
          title: Text(sync.running ? 'Sincronizando…' : 'Copia en la nube'),
          subtitle: Text(sync.error != null
              ? 'Falló: ${sync.error}'
              : last == null
                  ? 'Todavía no se ha sincronizado'
                  : 'Última vez: ${_ago(last)}'),
          trailing: IconButton(
            tooltip: 'Sincronizar ahora',
            icon: const Icon(Icons.sync),
            onPressed: sync.running
                ? null
                : () async {
                    await ref.read(syncProvider.notifier).syncNow();
                    await ref.read(accountProvider.notifier).refresh();
                  },
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Pueden ver tu armario'),
        ),
        ...invites.when(
          loading: () => [const LinearProgressIndicator()],
          error: (e, _) => [ListTile(title: Text('$e'))],
          data: (rows) => [
            for (final r in rows)
              ListTile(
                dense: true,
                leading: const Icon(Icons.visibility_outlined),
                title: Text(r.email),
                trailing: IconButton(
                  tooltip: 'Quitar acceso',
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    await ref
                        .read(convexProvider)
                        .mutation('invites:remove', {'id': r.id});
                    ref.invalidate(invitesProvider);
                  },
                ),
              ),
          ],
        ),
        ListTile(
          leading: const Icon(Icons.person_add_alt_outlined),
          title: const Text('Invitar por correo'),
          subtitle: const Text(
              'Esa persona entra con su Google y ve tu armario, sin poder '
              'cambiar nada'),
          onTap: () => _invite(context, ref),
        ),
        if (session.shared.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Compartidos contigo'),
          ),
          for (final s in session.shared)
            ListTile(
              leading: const Icon(Icons.checkroom_outlined),
              title: Text('Armario de ${s.ownerName}'),
              subtitle: Text(s.ownerEmail),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/shared/${s.closetId}'),
            ),
        ],
      ],
    );
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) => const _InviteDialog(),
    );
    if (email == null || email.trim().isEmpty) return;
    try {
      await ref.read(convexProvider).mutation('invites:add', {'email': email});
      ref.invalidate(invitesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Listo. Cuando ${email.trim()} entre con Google, '
              'verá tu armario en Ajustes.'),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'hace un momento';
    if (d.inHours < 1) return 'hace ${d.inMinutes} min';
    if (d.inDays < 1) return 'hace ${d.inHours} h';
    return 'hace ${d.inDays} días';
  }
}

/// El campo es del dialogo y no de quien lo abre: si lo libera quien lo
/// abre, la animacion de cierre todavia lo pinta y revienta.
class _InviteDialog extends StatefulWidget {
  const _InviteDialog();

  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invitar a ver tu armario'),
      content: TextField(
        controller: _ctl,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Correo de Google',
          hintText: 'alguien@gmail.com',
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: () => Navigator.pop(context, _ctl.text),
            child: const Text('Invitar')),
      ],
    );
  }
}
