import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/config.dart';
import '../../app/providers.dart';
import '../../data/prefs/app_prefs.dart';
import '../account/account_section.dart';
import '../../data/backup/wardrobe_backup.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

/// Interruptor y hora del aviso diario.
class _ReminderSection extends ConsumerWidget {
  const _ReminderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    final notifier = ref.read(appPrefsProvider.notifier);
    final time = TimeOfDay(
        hour: prefs.reminderMinutes ~/ 60, minute: prefs.reminderMinutes % 60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Aviso diario'),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('¿Qué me pongo hoy?'),
          subtitle: const Text(
              'Un aviso por la mañana con tu outfit planificado o una idea'),
          value: prefs.reminderEnabled,
          onChanged: (on) async {
            if (on) {
              final granted =
                  await ref.read(dailyReminderProvider).requestPermission();
              if (!granted) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Activa las notificaciones de Ivyroom en '
                        'los ajustes del teléfono.'),
                  ));
                }
                return;
              }
            }
            await notifier.change((p) => p.copyWith(reminderEnabled: on));
          },
        ),
        ListTile(
          enabled: prefs.reminderEnabled,
          leading: const Icon(Icons.schedule_outlined),
          title: const Text('Hora'),
          trailing: Text(time.format(context)),
          onTap: () async {
            final picked =
                await showTimePicker(context: context, initialTime: time);
            if (picked == null) return;
            await notifier.change((p) => p.copyWith(
                reminderMinutes: picked.hour * 60 + picked.minute));
          },
        ),
      ],
    );
  }
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;
  String? _busyLabel;

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(fullWardrobeProvider).value ?? const [];
    final storage = ref.watch(imageStorageProvider).value;
    // Para que el tamano se recalcule cuando la migracion de arranque acaba:
    // si no, la pantalla ensena lo que ocupaba antes de comprimir.
    ref.watch(imageMigrationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              if (AppConfig.cloudEnabled) ...[
                const AccountSection(),
                const Divider(height: 32),
              ],
              const _ReminderSection(),
              const Divider(height: 32),
              _SectionHeader('Respaldo'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Si no has iniciado sesión, todo se guarda solo en este '
                  'teléfono. Exporta de vez en cuando y guarda el archivo '
                  'donde quieras.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Exportar armario'),
                subtitle: Text('${wardrobe.length} prendas'
                    '${storage == null ? '' : ' · ${_size(storage.usedBytes())}'}'),
                onTap: _busy ? null : _export,
              ),
              ListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: const Text('Importar respaldo'),
                subtitle: const Text('Reemplaza el armario actual'),
                onTap: _busy ? null : _import,
              ),
              const Divider(height: 32),
              _SectionHeader('Almacenamiento'),
              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text('Liberar espacio'),
                subtitle: const Text(
                    'Borra fotos que ya no pertenecen a ninguna prenda'),
                onTap: _busy ? null : _prune,
              ),
            ],
          ),
          if (_busy)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (_busyLabel != null) ...[
                      const SizedBox(height: 16),
                      Text(_busyLabel!,
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<WardrobeBackup> _backup() async {
    final docs = await getApplicationDocumentsDirectory();
    return WardrobeBackup(
      // `driftDatabase(name: 'ivyroom')` guarda aquí.
      databaseFile: File('${docs.path}/ivyroom.sqlite'),
      imagesDirectory: Directory('${docs.path}/garments'),
    );
  }

  // ---- exportar ----------------------------------------------------------

  Future<void> _export() async {
    setState(() {
      _busy = true;
      _busyLabel = 'Empaquetando...';
    });
    try {
      final wardrobe = ref.read(fullWardrobeProvider).value ?? const [];
      final backup = await _backup();
      final bytes = await backup.export(garmentCount: wardrobe.length);

      // El zip va primero a la caché y de ahí al diálogo de compartir: en
      // Android una app no puede escribir en Descargas sin pasar por el
      // selector del sistema, y compartir cubre además mandarlo a Drive,
      // Telegram o a uno mismo por correo.
      final cache = await getTemporaryDirectory();
      final file = File(
          '${cache.path}/${WardrobeBackup.fileNameFor(DateTime.now())}');
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/zip')],
        text: 'Respaldo de Ivyroom · ${wardrobe.length} prendas',
      ));
    } catch (e) {
      _tell(e is BackupException ? e.message : 'No se pudo exportar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---- importar ----------------------------------------------------------

  Future<void> _import() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: true,
    );
    final file = picked?.files.firstOrNull;
    if (file == null || !mounted) return;

    final Uint8List bytes;
    if (file.bytes != null) {
      bytes = file.bytes!;
    } else if (file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    } else {
      _tell('No se pudo leer el archivo.');
      return;
    }

    // Se inspecciona y se confirma ANTES de tocar nada: importar borra el
    // armario actual y no hay vuelta atrás.
    final BackupSummary summary;
    try {
      summary = WardrobeBackup.inspect(bytes);
    } on BackupException catch (e) {
      _tell(e.message);
      return;
    }

    if (!mounted) return;
    final current = ref.read(fullWardrobeProvider).value?.length ?? 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importar respaldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('El respaldo tiene ${summary.garmentCount} prendas y se '
                'creó el ${_date(summary.createdAt)}.'),
            const SizedBox(height: 12),
            Text(
              current == 0
                  ? 'Tu armario está vacío, así que no se pierde nada.'
                  : 'Tus $current prendas actuales SE BORRARÁN y se '
                      'reemplazarán por las del respaldo. Esto no se puede '
                      'deshacer.',
              style: TextStyle(
                color: current == 0
                    ? null
                    : Theme.of(ctx).colorScheme.error,
                fontWeight: current == 0 ? null : FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Importar')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _busyLabel = 'Restaurando...';
    });
    try {
      // La base tiene que estar cerrada antes de sobrescribir el fichero:
      // drift no se entera de que el suelo se movió bajo sus pies.
      await ref.read(databaseProvider).close();
      final backup = await _backup();
      final restored = await backup.import(bytes);

      // Se invalidan los providers para que todo se relea de la base nueva.
      ref.invalidate(databaseProvider);
      ref.invalidate(imageStorageProvider);

      if (!mounted) return;
      _tell('Restauradas ${restored.garmentCount} prendas.');
    } catch (e) {
      _tell(e is BackupException ? e.message : 'No se pudo importar: $e');
      // Aunque falle hay que reabrir la base: si no, la app se queda con una
      // conexión cerrada y todo lo demás deja de funcionar.
      ref.invalidate(databaseProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---- limpieza ----------------------------------------------------------

  Future<void> _prune() async {
    setState(() {
      _busy = true;
      _busyLabel = 'Buscando archivos sueltos...';
    });
    try {
      final storage = await ref.read(imageStorageProvider.future);
      final referenced = {
        ...await ref.read(garmentRepositoryProvider).allImagePaths(),
        // Las fotos de looks viven en la misma carpeta: sin esto el barrido
        // las tomaria por huerfanas.
        ...await ref.read(planRepositoryProvider).allPhotoPaths(),
      };
      final freed = await storage.pruneOrphans(referenced);

      _tell(freed == 0
          ? 'No había nada que borrar.'
          : 'Liberados ${_size(freed)}.');
    } catch (e) {
      _tell('No se pudo limpiar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---- utilidades --------------------------------------------------------

  void _tell(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String _date(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} a las '
        '${two(d.hour)}:${two(d.minute)}';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toLowerCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
