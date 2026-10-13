import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/data/db/database.dart';
import 'package:ivyroom/data/repos/catalog_repository.dart';
import 'package:ivyroom/data/repos/garment_repository.dart';
import 'package:ivyroom/data/repos/laundry_repository.dart';
import 'package:ivyroom/data/repos/outfit_repository.dart';
import 'package:ivyroom/data/repos/plan_repository.dart';
import 'package:ivyroom/domain/models/catalog.dart';
import 'package:sqlite3/sqlite3.dart';

/// Crea a mano una base con el esquema v1, el que ya está instalado en el
/// teléfono. v1 guardaba categoría, ocasión y mood como el `name` del enum
/// de Dart; v2 los convierte en filas de catálogo.
///
/// Sin esta prueba, actualizar la app sobre una instalación con ropa dentro
/// sería un salto al vacío.
Database buildV1({
  List<(int id, String category, int argb, String? name)> garments = const [],
  List<(int garmentId, String occasion)> occasions = const [],
  List<(int garmentId, String mood)> moods = const [],
  List<(int id, String? occasion, String? mood)> outfits = const [],
}) {
  final db = sqlite3.openInMemory();

  db.execute('''
    CREATE TABLE garments (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      image_path TEXT NOT NULL,
      thumb_path TEXT NOT NULL,
      original_path TEXT NULL,
      category TEXT NOT NULL,
      dominant_color_argb INTEGER NOT NULL,
      palette_json TEXT NOT NULL DEFAULT '[]',
      name TEXT NULL,
      brand TEXT NULL,
      notes TEXT NULL,
      is_favorite INTEGER NOT NULL DEFAULT 0,
      is_archived INTEGER NOT NULL DEFAULT 0,
      wear_count INTEGER NOT NULL DEFAULT 0,
      last_worn_at INTEGER NULL,
      created_at INTEGER NOT NULL
    );
    CREATE TABLE tags (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    );
    CREATE TABLE garment_tags (
      garment_id INTEGER NOT NULL, tag_id INTEGER NOT NULL,
      PRIMARY KEY (garment_id, tag_id)
    );
    CREATE TABLE garment_seasons (
      garment_id INTEGER NOT NULL, season TEXT NOT NULL,
      PRIMARY KEY (garment_id, season)
    );
    CREATE TABLE garment_occasions (
      garment_id INTEGER NOT NULL, occasion TEXT NOT NULL,
      PRIMARY KEY (garment_id, occasion)
    );
    CREATE TABLE garment_moods (
      garment_id INTEGER NOT NULL, mood TEXT NOT NULL,
      PRIMARY KEY (garment_id, mood)
    );
    CREATE TABLE outfits (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NULL, occasion TEXT NULL, mood TEXT NULL, notes TEXT NULL,
      wear_count INTEGER NOT NULL DEFAULT 0,
      last_worn_at INTEGER NULL, created_at INTEGER NOT NULL
    );
    CREATE TABLE outfit_items (
      outfit_id INTEGER NOT NULL, garment_id INTEGER NOT NULL,
      slot TEXT NOT NULL, PRIMARY KEY (outfit_id, garment_id)
    );
  ''');

  db.execute('PRAGMA user_version = 1');

  final created = DateTime(2026, 8, 22).millisecondsSinceEpoch ~/ 1000;
  for (final (id, category, argb, name) in garments) {
    db.execute(
      'INSERT INTO garments (id, image_path, thumb_path, category, '
      'dominant_color_argb, name, created_at) VALUES (?,?,?,?,?,?,?)',
      [id, 'garments/g$id.png', 'garments/g${id}_thumb.png', category, argb,
        name, created],
    );
  }
  for (final (gid, occ) in occasions) {
    db.execute(
        'INSERT INTO garment_occasions (garment_id, occasion) VALUES (?,?)',
        [gid, occ]);
  }
  for (final (gid, mood) in moods) {
    db.execute('INSERT INTO garment_moods (garment_id, mood) VALUES (?,?)',
        [gid, mood]);
  }
  for (final (id, occ, mood) in outfits) {
    db.execute(
      'INSERT INTO outfits (id, occasion, mood, created_at) VALUES (?,?,?,?)',
      [id, occ, mood, created],
    );
  }
  return db;
}

void main() {
  Future<AppDatabase> upgrade(Database v1) async {
    final db = AppDatabase.forTesting(NativeDatabase.opened(v1));
    // Una consulta cualquiera dispara la migración.
    await db.customSelect('SELECT 1').get();
    return db;
  }

  _v4Tests();
  _v5Tests();
  _v5BackfillTests();
  _v6Tests();
  _v7Tests();

  test('actualizar una base v1 vacía crea y siembra los catálogos', () async {
    final db = await upgrade(buildV1());
    addTearDown(db.close);

    final cats = await CatalogRepository(db).categories();
    expect(cats, isNotEmpty);
    expect(cats.map((c) => c.name), contains('Zapatos'));
  });

  test('las prendas sobreviven y conservan su tipo traducido', () async {
    final db = await upgrade(buildV1(garments: [
      (1, 'sneakers', 0xFF1A1A1A, 'Vans negras'),
      (2, 'tshirt', 0xFFDC1E1E, null),
      (3, 'coat', 0xFF303030, 'Abrigo largo'),
    ]));
    addTearDown(db.close);

    final all = await GarmentRepository(db).getAll();
    expect(all, hasLength(3));

    final byName = {for (final g in all) g.id: g};
    // "sneakers" en v1 pasa a "Tenis", que es como se dice en Colombia.
    expect(byName[1]!.category.name, 'Tenis');
    expect(byName[1]!.slot, Slot.shoes);
    expect(byName[1]!.name, 'Vans negras');
    expect(byName[2]!.category.name, 'Camiseta');
    expect(byName[2]!.slot, Slot.top);
    expect(byName[3]!.category.name, 'Abrigo');
    expect(byName[3]!.slot, Slot.outer);
  });

  test('rellena la familia de color de las prendas ya existentes', () async {
    final db = await upgrade(buildV1(garments: [
      (1, 'tshirt', 0xFFDC1E1E, null), // rojo
      (2, 'jeans', 0xFF1E5ADC, null), // azul
    ]));
    addTearDown(db.close);

    final repo = GarmentRepository(db);
    final reds = await repo
        .watchFiltered(const ClosetFilter(colorFamilies: {ColorFamily.red}))
        .first;
    expect(reds.map((g) => g.id), [1]);

    final blues = await repo
        .watchFiltered(const ClosetFilter(colorFamilies: {ColorFamily.blue}))
        .first;
    expect(blues.map((g) => g.id), [2]);
  });

  test('las ocasiones y moods etiquetados se traducen a ids', () async {
    final db = await upgrade(buildV1(
      garments: [(1, 'shirt', 0xFFF2F2F2, null)],
      occasions: [(1, 'work'), (1, 'formal')],
      moods: [(1, 'elegant')],
    ));
    addTearDown(db.close);

    final g = (await GarmentRepository(db).getAll()).single;
    expect(g.occasions.map((o) => o.name), {'Trabajo', 'Formal'});
    expect(g.moods.map((m) => m.name), {'Elegante'});
  });

  test('un enum desconocido de v1 no pierde la prenda', () async {
    // Una categoría que no esté en el mapa de traducción cae al respaldo:
    // perder ropa al actualizar sería lo peor que podría pasar aquí.
    final db = await upgrade(buildV1(garments: [
      (1, 'categoria_inventada', 0xFF1A1A1A, 'Rara'),
    ]));
    addTearDown(db.close);

    final all = await GarmentRepository(db).getAll();
    expect(all, hasLength(1));
    expect(all.single.name, 'Rara');
    expect(all.single.category.name, CatalogSeed.fallbackCategory);
  });

  test('los outfits guardados conservan ocasión y mood', () async {
    final db = await upgrade(buildV1(
      garments: [(1, 'shirt', 0xFFF2F2F2, null)],
      outfits: [(1, 'work', 'elegant'), (2, null, null)],
    ));
    addTearDown(db.close);

    final rows = await db.customSelect(
      'SELECT id, occasion_id, mood_id FROM outfits ORDER BY id',
    ).get();
    expect(rows, hasLength(2));
    expect(rows.first.read<int?>('occasion_id'), isNotNull);
    expect(rows.first.read<int?>('mood_id'), isNotNull);
    expect(rows.last.read<int?>('occasion_id'), isNull);
  });

  test('las columnas viejas desaparecen del esquema', () async {
    final db = await upgrade(buildV1(garments: [(1, 'tshirt', 0xFF1A1A1A, null)]));
    addTearDown(db.close);

    final cols = await db.customSelect('PRAGMA table_info(garments)').get();
    final names = cols.map((c) => c.read<String>('name')).toSet();
    expect(names, contains('category_id'));
    expect(names, contains('color_family'));
    expect(names, isNot(contains('category')));
  });

  test('tras migrar se pueden seguir dando de alta prendas', () async {
    final db = await upgrade(buildV1(garments: [(1, 'tshirt', 0xFF1A1A1A, null)]));
    addTearDown(db.close);

    final cats = await CatalogRepository(db).categories();
    final id = await GarmentRepository(db).insert(GarmentDraft(
      imagePath: 'garments/nueva.png',
      thumbPath: 'garments/nueva_thumb.png',
      categoryId: cats.firstWhere((c) => c.name == 'Jean').id,
      dominantColorArgb: 0xFF1E5ADC,
    ));

    expect((await GarmentRepository(db).findById(id))!.category.name, 'Jean');
    expect(await GarmentRepository(db).getAll(), hasLength(2));
  });
}

// ---- v3 -> v4: registro de lavado -------------------------------------------

/// Base v3 mínima: la que tiene el teléfono ahora mismo, con catálogos y
/// calendario pero sin nada de lavado.
Database buildV3({List<(int id, String? name)> garments = const []}) {
  final db = sqlite3.openInMemory();
  db.execute('''
    CREATE TABLE categories (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE, slot TEXT NOT NULL,
      formality INTEGER NOT NULL DEFAULT 2, warmth INTEGER NOT NULL DEFAULT 1,
      is_built_in INTEGER NOT NULL DEFAULT 0,
      sort_order INTEGER NOT NULL DEFAULT 0);
    CREATE TABLE occasions (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE, formality INTEGER NOT NULL DEFAULT 2,
      is_built_in INTEGER NOT NULL DEFAULT 0,
      sort_order INTEGER NOT NULL DEFAULT 0);
    CREATE TABLE moods (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE, is_built_in INTEGER NOT NULL DEFAULT 0,
      sort_order INTEGER NOT NULL DEFAULT 0);
    CREATE TABLE tags (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE);
    CREATE TABLE garments (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      image_path TEXT NOT NULL, thumb_path TEXT NOT NULL,
      original_path TEXT NULL, category_id INTEGER NOT NULL,
      dominant_color_argb INTEGER NOT NULL, color_family TEXT NOT NULL,
      palette_json TEXT NOT NULL DEFAULT '[]', name TEXT NULL,
      brand TEXT NULL, notes TEXT NULL,
      is_favorite INTEGER NOT NULL DEFAULT 0,
      is_archived INTEGER NOT NULL DEFAULT 0,
      wear_count INTEGER NOT NULL DEFAULT 0, last_worn_at INTEGER NULL,
      created_at INTEGER NOT NULL);
    CREATE TABLE garment_tags (
      garment_id INTEGER NOT NULL, tag_id INTEGER NOT NULL,
      PRIMARY KEY (garment_id, tag_id));
    CREATE TABLE garment_seasons (
      garment_id INTEGER NOT NULL, season TEXT NOT NULL,
      PRIMARY KEY (garment_id, season));
    CREATE TABLE garment_occasions (
      garment_id INTEGER NOT NULL, occasion_id INTEGER NOT NULL,
      PRIMARY KEY (garment_id, occasion_id));
    CREATE TABLE garment_moods (
      garment_id INTEGER NOT NULL, mood_id INTEGER NOT NULL,
      PRIMARY KEY (garment_id, mood_id));
    CREATE TABLE outfits (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT NULL,
      occasion_id INTEGER NULL, mood_id INTEGER NULL, notes TEXT NULL,
      wear_count INTEGER NOT NULL DEFAULT 0, last_worn_at INTEGER NULL,
      created_at INTEGER NOT NULL);
    CREATE TABLE outfit_items (
      outfit_id INTEGER NOT NULL, garment_id INTEGER NOT NULL,
      slot TEXT NOT NULL, PRIMARY KEY (outfit_id, garment_id));
    CREATE TABLE outfit_plans (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      day INTEGER NOT NULL UNIQUE, outfit_id INTEGER NULL, notes TEXT NULL,
      was_worn INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL);
    CREATE TABLE plan_items (
      plan_id INTEGER NOT NULL, garment_id INTEGER NOT NULL,
      PRIMARY KEY (plan_id, garment_id));
  ''');
  db.execute('PRAGMA user_version = 3');

  db.execute("INSERT INTO categories (id, name, slot) VALUES (1, 'Camiseta', 'top')");
  final created = DateTime(2026, 8, 22).millisecondsSinceEpoch ~/ 1000;
  for (final (id, name) in garments) {
    db.execute(
      'INSERT INTO garments (id, image_path, thumb_path, category_id, '
      'dominant_color_argb, color_family, name, wear_count, created_at) '
      "VALUES (?,?,?,1,?, 'neutral', ?, 3, ?)",
      [id, 'g$id.png', 'g${id}_t.png', 0xFF1A1A1A, name, created],
    );
  }
  return db;
}

void _v4Tests() {
  Future<AppDatabase> upgrade(Database v3) async {
    final db = AppDatabase.forTesting(NativeDatabase.opened(v3));
    await db.customSelect('SELECT 1').get();
    return db;
  }

  group('v3 -> v4', () {
    test('crea las tablas de lavado y siembra los grupos', () async {
      final db = await upgrade(buildV3());
      addTearDown(db.close);

      final groups = await WashGroupRepository(db).all();
      expect(groups.map((g) => g.name),
          containsAll(['Oscuros', 'Normal', 'Ropa pesada', 'Delicados']));
    });

    test('las prendas existentes sobreviven, sin lavadas', () async {
      final db = await upgrade(buildV3(garments: [(1, 'Camiseta blanca')]));
      addTearDown(db.close);

      final g = (await GarmentRepository(db).getAll()).single;
      expect(g.name, 'Camiseta blanca');
      expect(g.wearCount, 3);
      expect(g.washCount, 0);
      expect(g.lastWashedAt, isNull);
      expect(g.washGroup, isNull);
    });

    test('tras migrar se puede registrar una lavada', () async {
      final db = await upgrade(buildV3(garments: [(1, 'Camiseta')]));
      addTearDown(db.close);

      final garments = GarmentRepository(db);
      final laundry = LaundryRepository(db, garments);
      final g = (await garments.getAll()).single;

      await laundry.record(DateTime(2026, 8, 23), [g]);

      final after = (await garments.getAll()).single;
      expect(after.washCount, 1);
      expect(LaundryRepository.dayKey(after.lastWashedAt!),
          DateTime(2026, 8, 23));
    });

    test('los outfits ganan la columna de favorito', () async {
      final db = await upgrade(buildV3());
      addTearDown(db.close);

      final cols = await db.customSelect('PRAGMA table_info(outfits)').get();
      expect(cols.map((c) => c.read<String>('name')),
          contains('is_favorite'));
    });
  });
}

// ---- v4 -> v5: momento real de la lavada -------------------------------------

/// Base v4: la que el telefono tenia justo antes de v5, con lavadas ya
/// registradas pero sin la columna del momento real.
///
/// Este builder existe porque la primera version de la migracion v5 fallaba
/// exactamente aqui y los tests no lo vieron: cubrian v1->ultima y
/// v3->ultima, donde el bloque de v4 no llega a ejecutarse nunca.
Database buildV4({
  List<(int id, String name)> garments = const [],
  List<(int day, List<int> garmentIds)> washes = const [],
}) {
  final db = buildV3(garments: [for (final (id, n) in garments) (id, n)]);

  db.execute('''
    ALTER TABLE garments ADD COLUMN wash_group_id INTEGER NULL;
    ALTER TABLE garments ADD COLUMN wash_count INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE garments ADD COLUMN last_washed_at INTEGER NULL;
    ALTER TABLE garments ADD COLUMN wears_since_wash INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE outfits ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0;
    CREATE TABLE wash_groups (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      is_built_in INTEGER NOT NULL DEFAULT 0,
      sort_order INTEGER NOT NULL DEFAULT 0);
    CREATE TABLE laundry_days (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      day INTEGER NOT NULL UNIQUE, notes TEXT NULL,
      created_at INTEGER NOT NULL);
    CREATE TABLE laundry_items (
      laundry_day_id INTEGER NOT NULL, garment_id INTEGER NOT NULL,
      PRIMARY KEY (laundry_day_id, garment_id));
  ''');
  db.execute("INSERT INTO wash_groups (name, is_built_in) VALUES ('Oscuros', 1)");
  db.execute('PRAGMA user_version = 4');

  for (final (day, ids) in washes) {
    db.execute(
      'INSERT INTO laundry_days (day, created_at) VALUES (?, ?)',
      [day, day],
    );
    final laundryId = db.lastInsertRowId;
    for (final gid in ids) {
      db.execute(
        'INSERT INTO laundry_items (laundry_day_id, garment_id) VALUES (?,?)',
        [laundryId, gid],
      );
      db.execute(
        'UPDATE garments SET wash_count = wash_count + 1, last_washed_at = ? '
        'WHERE id = ?',
        [day, gid],
      );
    }
  }
  return db;
}

void _v5Tests() {
  Future<AppDatabase> upgrade(Database v4) async {
    final db = AppDatabase.forTesting(NativeDatabase.opened(v4));
    await db.customSelect('SELECT 1').get();
    return db;
  }

  final lunes = DateTime(2026, 8, 24);

  group('v4 -> v5', () {
    test('una base v4 vacía migra sin romperse', () async {
      final db = await upgrade(buildV4());
      addTearDown(db.close);

      // Llega hasta la ultima version, sea cual sea.
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        db.schemaVersion,
      );
    });

    test('una base v4 CON lavadas registradas migra', () async {
      // Este es el caso que fallaba: `ALTER TABLE ADD COLUMN NOT NULL` sin
      // default es ilegal en SQLite, y la app se quedaba cargando.
      final db = await upgrade(buildV4(
        garments: [(1, 'Camiseta')],
        washes: [(lunes.millisecondsSinceEpoch ~/ 1000, [1])],
      ));
      addTearDown(db.close);

      final garments = GarmentRepository(db);
      final g = (await garments.getAll()).single;
      expect(g.name, 'Camiseta');
      expect(g.washCount, 1);
    });

    test('las lavadas viejas se dan por hechas al final de su día', () async {
      final db = await upgrade(buildV4(
        garments: [(1, 'Camiseta')],
        washes: [(lunes.millisecondsSinceEpoch ~/ 1000, [1])],
      ));
      addTearDown(db.close);

      final row = await db
          .customSelect('SELECT day, washed_at FROM laundry_days')
          .getSingle();
      final day = row.read<int>('day');
      final washedAt = row.read<int>('washed_at');

      // 23:59:59 del mismo día: sin hora conocida, asumir que se lavó
      // después de usarlo es lo que menos sorprende.
      expect(washedAt - day, 86399);
    });

    test('el historial de lavadas sigue siendo legible tras migrar', () async {
      final db = await upgrade(buildV4(
        garments: [(1, 'Camiseta')],
        washes: [(lunes.millisecondsSinceEpoch ~/ 1000, [1])],
      ));
      addTearDown(db.close);

      final garments = GarmentRepository(db);
      final days = await LaundryRepository(db, garments).watchAll().first;
      expect(days, hasLength(1));
      expect(days.single.items.map((g) => g.name), ['Camiseta']);
    });

    test('tras migrar se puede registrar otra lavada', () async {
      final db = await upgrade(buildV4(
        garments: [(1, 'Camiseta')],
        washes: [(lunes.millisecondsSinceEpoch ~/ 1000, [1])],
      ));
      addTearDown(db.close);

      final garments = GarmentRepository(db);
      final laundry = LaundryRepository(db, garments);
      final g = (await garments.getAll()).single;

      await laundry.record(DateTime(2026, 8, 30), [g]);

      expect((await garments.getAll()).single.washCount, 2);
    });
  });
}

void _v5BackfillTests() {
  Future<AppDatabase> upgrade(Database v4) async {
    final db = AppDatabase.forTesting(NativeDatabase.opened(v4));
    await db.customSelect('SELECT 1').get();
    return db;
  }

  group('v4 -> v5: la copia de la última lavada en la prenda', () {
    test('se refresca al momento real, no se queda en la medianoche',
        () async {
      // El fallo que se vio con datos reales: la prenda seguía marcada como
      // sucia tras migrar porque su copia apuntaba a las 00:00 del día.
      final day = DateTime(2026, 9, 5);
      final dayTs = day.millisecondsSinceEpoch ~/ 1000;

      final v4 = buildV4(
        garments: [(1, 'Camiseta')],
        washes: [(dayTs, [1])],
      );
      // Usada a las 22:07 de ese mismo día, después de la medianoche vieja
      // pero antes del final del día.
      v4.execute('UPDATE garments SET last_worn_at = ? WHERE id = 1',
          [DateTime(2026, 9, 5, 22, 7).millisecondsSinceEpoch ~/ 1000]);

      final db = await upgrade(v4);
      addTearDown(db.close);

      final g = (await GarmentRepository(db).getAll()).single;
      expect(g.lastWashedAt!.hour, 23);
      expect(g.needsWashing, isFalse);
      expect(g.wearsSinceWash, 0);
    });

    test('lo usado un día posterior a la lavada sigue sucio', () async {
      final dayTs = DateTime(2026, 9, 5).millisecondsSinceEpoch ~/ 1000;
      final v4 = buildV4(
        garments: [(1, 'Camiseta')],
        washes: [(dayTs, [1])],
      );
      v4.execute('UPDATE garments SET last_worn_at = ? WHERE id = 1',
          [DateTime(2026, 9, 7, 10).millisecondsSinceEpoch ~/ 1000]);

      final db = await upgrade(v4);
      addTearDown(db.close);

      final g = (await GarmentRepository(db).getAll()).single;
      expect(g.needsWashing, isTrue);
      expect(g.wearsSinceWash, 1);
    });

    test('una prenda sin lavadas conserva sus usos como pendientes',
        () async {
      final v4 = buildV4(garments: [(1, 'Camiseta')]);
      final db = await upgrade(v4);
      addTearDown(db.close);

      final g = (await GarmentRepository(db).getAll()).single;
      expect(g.lastWashedAt, isNull);
      // El builder deja wear_count en 3.
      expect(g.wearsSinceWash, 3);
    });
  });
}

void _v6Tests() {
  /// Base v5 con la migración a medias: la tabla ya tiene `washed_at` pero
  /// la copia de la prenda se quedó en la medianoche vieja. Es exactamente
  /// el estado en el que quedó el teléfono.
  Database buildBrokenV5() {
    final day = DateTime(2026, 9, 5);
    final dayTs = day.millisecondsSinceEpoch ~/ 1000;
    final db = buildV4(garments: [(1, 'Camiseta')], washes: [(dayTs, [1])]);

    db.execute('''
      CREATE TABLE laundry_days_new (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        day INTEGER NOT NULL UNIQUE, washed_at INTEGER NOT NULL,
        notes TEXT NULL, created_at INTEGER NOT NULL);
      INSERT INTO laundry_days_new (id, day, washed_at, notes, created_at)
        SELECT id, day, day + 86399, notes, created_at FROM laundry_days;
      DROP TABLE laundry_days;
      ALTER TABLE laundry_days_new RENAME TO laundry_days;
    ''');
    // La copia se queda vieja: el fallo.
    db.execute('UPDATE garments SET last_washed_at = ?, last_worn_at = ?',
        [dayTs, DateTime(2026, 9, 5, 22, 7).millisecondsSinceEpoch ~/ 1000]);
    db.execute('PRAGMA user_version = 5');
    return db;
  }

  test('v5 a medias se repara al abrir', () async {
    final db = AppDatabase.forTesting(NativeDatabase.opened(buildBrokenV5()));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final g = (await GarmentRepository(db).getAll()).single;
    expect(g.lastWashedAt!.hour, 23);
    expect(g.needsWashing, isFalse);
  });
}

void _v7Tests() {
  test('v6 -> v7: el día deja de ser único y los planes sobreviven',
      () async {
    // La v6 tenía UNIQUE en `day`. Quitarlo obliga a recrear la tabla, así
    // que hay que comprobar que lo planificado no se pierde por el camino.
    final day = DateTime(2026, 9, 8);
    // Los dias se guardan a medianoche LOCAL: un timestamp cualquiera no
    // coincidiria con lo que busca `forDay`.
    final dayTs = day.millisecondsSinceEpoch ~/ 1000;

    final v6 = buildV4(garments: [(1, 'Camiseta')]);
    v6.execute(
      'ALTER TABLE laundry_days ADD COLUMN washed_at INTEGER NOT NULL '
      'DEFAULT 0',
    );
    v6.execute(
      'INSERT INTO outfit_plans (day, notes, was_worn, created_at) '
      "VALUES (?, 'el martes', 1, ?)",
      [dayTs, dayTs],
    );
    v6.execute('INSERT INTO plan_items (plan_id, garment_id) VALUES (1, 1)');
    v6.execute('PRAGMA user_version = 6');

    final db = AppDatabase.forTesting(NativeDatabase.opened(v6));
    addTearDown(db.close);

    final garments = GarmentRepository(db);
    final plans = PlanRepository(db, garments, OutfitRepository(db, garments));

    final existing = await plans.forDay(day);
    expect(existing, hasLength(1));
    expect(existing.single.notes, 'el martes');
    expect(existing.single.wasWorn, isTrue);
    expect(existing.single.items.map((g) => g.name), ['Camiseta']);

    // Y ahora sí admite una segunda opción el mismo día.
    await plans.addPlan(day, garments: existing.single.items);
    expect(await plans.forDay(day), hasLength(2));
  });
}
