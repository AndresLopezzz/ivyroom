import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/color/color_theory.dart';
import '../../domain/models/catalog.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Occasions,
    Moods,
    WashGroups,
    Tags,
    Garments,
    GarmentTags,
    GarmentSeasons,
    GarmentOccasions,
    GarmentMoods,
    Outfits,
    OutfitItems,
    OutfitPlans,
    PlanItems,
    LaundryDays,
    LaundryItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'ivyroom'));

  /// Constructor para tests: base en memoria, sin tocar disco.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedCatalogs();
          await _seedWashGroups();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await _migrateToCatalogs(m);
          if (from < 3) {
            // v3 solo anade el calendario: tablas nuevas, nada que traducir.
            await m.createTable(outfitPlans);
            await m.createTable(planItems);
          }
          if (from < 4) {
            // v4 anade el registro de lavado. Las columnas nuevas de
            // `garments` arrancan a cero y en null, que es exactamente lo
            // que significa "nunca se ha lavado".
            await m.createTable(washGroups);
            await m.createTable(laundryDays);
            await m.createTable(laundryItems);
            await m.addColumn(garments, garments.washGroupId);
            await m.addColumn(garments, garments.washCount);
            await m.addColumn(garments, garments.lastWashedAt);
            await m.addColumn(garments, garments.wearsSinceWash);
            await m.addColumn(outfits, outfits.isFavorite);
            await _seedWashGroups();
          }
          if (from == 4) {
            await _addWashedAt();
            await _refreshGarmentWashCopies();
          }
          // v6 solo repite el refresco: la primera version de v5 recreaba la
          // tabla pero se olvidaba de actualizar la copia que llevan las
          // prendas, y las que se habian usado el mismo dia de la lavada
          // seguian saliendo como sucias.
          if (from == 5) await _refreshGarmentWashCopies();
          if (from < 7) await _allowSeveralPlansPerDay();
          if (from < 8) await m.addColumn(outfitPlans, outfitPlans.photoPath);
        },
        beforeOpen: (details) async {
          // Sin esto SQLite ignora las FK y los ON DELETE de las tablas
          // puente no se aplican.
          await customStatement('PRAGMA foreign_keys = ON');

          // Una base que se quedó sin catálogos (por un borrado en cadena o
          // un backup a medias) dejaría la app sin poder dar de alta nada.
          if (details.wasCreated) return;
          final count = await managers.categories.count();
          if (count == 0) await _seedCatalogs();
          if (await managers.washGroups.count() == 0) await _seedWashGroups();
        },
      );

  /// v1 guardaba categoría, ocasión y mood como texto del nombre del enum.
  /// v2 los convierte en filas. La migración crea los catálogos y traduce lo
  /// que ya hubiera, para no perder las prendas que el usuario tenga.
  Future<void> _migrateToCatalogs(Migrator m) async {
    await customStatement('PRAGMA foreign_keys = OFF');

    await m.createTable(categories);
    await m.createTable(occasions);
    await m.createTable(moods);
    await _seedCatalogs();

    // Nombre del enum de v1 -> nombre de catálogo de v2.
    const catMap = {
      'tshirt': 'Camiseta', 'shirt': 'Camisa', 'blouse': 'Blusa',
      'sweater': 'Suéter', 'hoodie': 'Buzo', 'tankTop': 'Top',
      'jeans': 'Jean', 'trousers': 'Pantalón', 'shorts': 'Short',
      'skirt': 'Falda', 'joggers': 'Pantalón deportivo',
      'dress': 'Vestido', 'jumpsuit': 'Enterizo',
      'jacket': 'Chaqueta', 'coat': 'Abrigo', 'blazer': 'Blazer',
      'cardigan': 'Cárdigan',
      'sneakers': 'Tenis', 'boots': 'Botas', 'heels': 'Tacones',
      'flats': 'Baletas', 'sandals': 'Sandalias',
      'bag': 'Bolso', 'hat': 'Gorra', 'scarf': 'Bufanda',
      'belt': 'Cinturón', 'jewelry': 'Accesorio', 'other': 'Accesorio',
    };
    const occMap = {
      'casual': 'Casual', 'work': 'Trabajo', 'formal': 'Formal',
      'party': 'Fiesta', 'sport': 'Deporte', 'home': 'Casa',
      'date': 'Cita', 'travel': 'Viaje',
    };
    const moodMap = {
      'chill': 'Relajado', 'bold': 'Atrevido', 'elegant': 'Elegante',
      'playful': 'Divertido', 'minimal': 'Minimalista', 'cozy': 'Cómodo',
      'edgy': 'Rockero', 'romantic': 'Romántico',
    };

    Future<Map<String, int>> idsByName(String table) async {
      final rows = await customSelect('SELECT id, name FROM $table').get();
      return {
        for (final r in rows) r.read<String>('name'): r.read<int>('id'),
      };
    }

    final catIds = await idsByName('categories');
    final occIds = await idsByName('occasions');
    final moodIds = await idsByName('moods');
    final fallbackId = catIds[CatalogSeed.fallbackCategory] ??
        catIds.values.first;

    // Las prendas: se añaden category_id y color_family y se rellenan desde
    // las columnas viejas antes de tirarlas.
    await customStatement(
        'ALTER TABLE garments ADD COLUMN category_id INTEGER NOT NULL DEFAULT 0');
    await customStatement(
        "ALTER TABLE garments ADD COLUMN color_family TEXT NOT NULL DEFAULT 'neutral'");

    final oldGarments = await customSelect(
      'SELECT id, category, dominant_color_argb FROM garments',
    ).get();
    for (final row in oldGarments) {
      final id = row.read<int>('id');
      final legacy = row.read<String>('category');
      final argb = row.read<int>('dominant_color_argb');
      await customStatement(
        'UPDATE garments SET category_id = ?, color_family = ? WHERE id = ?',
        [
          catIds[catMap[legacy]] ?? fallbackId,
          Hsl.fromArgb(argb).family.name,
          id,
        ],
      );
    }
    await customStatement('ALTER TABLE garments DROP COLUMN category');

    // Las puentes de ocasión y mood pasan de texto a id. Se reconstruyen
    // enteras porque cambia el tipo de la columna.
    Future<void> rebuildLink(
      String table,
      String oldCol,
      String newCol,
      Map<String, String> nameMap,
      Map<String, int> ids,
    ) async {
      final rows =
          await customSelect('SELECT garment_id, $oldCol FROM $table').get();
      final pairs = <(int, int)>[];
      for (final r in rows) {
        final target = ids[nameMap[r.read<String>(oldCol)]];
        if (target != null) pairs.add((r.read<int>('garment_id'), target));
      }
      await customStatement('DROP TABLE $table');
      await customStatement(
        'CREATE TABLE $table (garment_id INTEGER NOT NULL, '
        '$newCol INTEGER NOT NULL, PRIMARY KEY (garment_id, $newCol))',
      );
      for (final (g, t) in pairs) {
        await customStatement(
          'INSERT OR IGNORE INTO $table (garment_id, $newCol) VALUES (?, ?)',
          [g, t],
        );
      }
    }

    await rebuildLink(
        'garment_occasions', 'occasion', 'occasion_id', occMap, occIds);
    await rebuildLink('garment_moods', 'mood', 'mood_id', moodMap, moodIds);

    // Los outfits guardados referenciaban ocasión y mood por nombre de enum.
    await customStatement(
        'ALTER TABLE outfits ADD COLUMN occasion_id INTEGER');
    await customStatement('ALTER TABLE outfits ADD COLUMN mood_id INTEGER');
    final oldOutfits =
        await customSelect('SELECT id, occasion, mood FROM outfits').get();
    for (final r in oldOutfits) {
      await customStatement(
        'UPDATE outfits SET occasion_id = ?, mood_id = ? WHERE id = ?',
        [
          occIds[occMap[r.read<String?>('occasion')]],
          moodIds[moodMap[r.read<String?>('mood')]],
          r.read<int>('id'),
        ],
      );
    }
    await customStatement('ALTER TABLE outfits DROP COLUMN occasion');
    await customStatement('ALTER TABLE outfits DROP COLUMN mood');

    await customStatement('PRAGMA foreign_keys = ON');
  }

  /// v5 separa el momento real de la lavada del dia normalizado.
  ///
  /// Se recrea la tabla en vez de usar `ALTER TABLE ADD COLUMN`: SQLite no
  /// acepta anadir una columna NOT NULL sin default, ni con un default no
  /// constante como la fecha actual. Recrearla ademas deja el esquema
  /// identico en una instalacion nueva y en una migrada, sin la columna
  /// fantasma con DEFAULT que dejaria el atajo.
  Future<void> _addWashedAt() async {
    await customStatement('PRAGMA foreign_keys = OFF');
    await customStatement('''
      CREATE TABLE laundry_days_new (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        day INTEGER NOT NULL UNIQUE,
        washed_at INTEGER NOT NULL,
        notes TEXT NULL,
        created_at INTEGER NOT NULL)
    ''');
    // Las lavadas ya registradas se dan por hechas al final de su dia: sin
    // hora conocida, asumir que se lavo despues de haberlo usado ese dia es
    // lo que menos sorprende.
    await customStatement('''
      INSERT INTO laundry_days_new (id, day, washed_at, notes, created_at)
      SELECT id, day, day + 86399, notes, created_at FROM laundry_days
    ''');
    await customStatement('DROP TABLE laundry_days');
    await customStatement(
        'ALTER TABLE laundry_days_new RENAME TO laundry_days');

    await customStatement('PRAGMA foreign_keys = ON');
  }

  /// v7 quita la unicidad del dia en el calendario.
  ///
  /// Se recrea la tabla porque en SQLite un indice UNIQUE declarado en el
  /// CREATE TABLE no se puede quitar con ALTER.
  Future<void> _allowSeveralPlansPerDay() async {
    await customStatement('PRAGMA foreign_keys = OFF');
    await customStatement('''
      CREATE TABLE outfit_plans_new (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        day INTEGER NOT NULL,
        outfit_id INTEGER NULL REFERENCES outfits (id) ON DELETE SET NULL,
        notes TEXT NULL,
        was_worn INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL)
    ''');
    await customStatement('''
      INSERT INTO outfit_plans_new (id, day, outfit_id, notes, was_worn,
        created_at)
      SELECT id, day, outfit_id, notes, was_worn, created_at
      FROM outfit_plans
    ''');
    await customStatement('DROP TABLE outfit_plans');
    await customStatement(
        'ALTER TABLE outfit_plans_new RENAME TO outfit_plans');
    await customStatement('PRAGMA foreign_keys = ON');
  }

  /// Vuelve a copiar en cada prenda su ultima lavada a partir del historial.
  ///
  /// Las prendas llevan copiada esa fecha para no recorrer el historial en
  /// cada consulta, y cualquier cambio en `laundry_days` la deja obsoleta.
  /// Es idempotente a proposito: se puede repetir sin efectos.
  Future<void> _refreshGarmentWashCopies() async {
    await customStatement('''
      UPDATE garments SET last_washed_at = (
        SELECT MAX(d.washed_at) FROM laundry_items i
        JOIN laundry_days d ON d.id = i.laundry_day_id
        WHERE i.garment_id = garments.id)
      WHERE EXISTS (
        SELECT 1 FROM laundry_items i WHERE i.garment_id = garments.id)
    ''');

    // Y los usos desde la ultima lavada, con el mismo criterio que usa el
    // recalculo normal.
    await customStatement('''
      UPDATE garments SET wears_since_wash = CASE
        WHEN last_washed_at IS NULL THEN wear_count
        WHEN last_worn_at IS NOT NULL AND last_worn_at > last_washed_at
          THEN 1
        ELSE 0 END
    ''');
  }

  Future<void> _seedWashGroups() async {
    await batch((b) {
      var order = 0;
      b.insertAll(
        washGroups,
        [
          for (final name in CatalogSeed.washGroups)
            WashGroupsCompanion.insert(
              name: name,
              isBuiltIn: const Value(true),
              sortOrder: Value(order++),
            ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> _seedCatalogs() async {
    await batch((b) {
      var order = 0;
      b.insertAll(
        categories,
        [
          for (final (name, slot, formality, warmth) in CatalogSeed.categories)
            CategoriesCompanion.insert(
              name: name,
              slot: slot.name,
              formality: Value(formality),
              warmth: Value(warmth),
              isBuiltIn: const Value(true),
              sortOrder: Value(order++),
            ),
          // Destino de las prendas cuya categoría se borre. Se crea desde el
          // principio para que borrar nunca pueda fallar por no tener a dónde
          // mover la ropa.
          CategoriesCompanion.insert(
            name: CatalogSeed.fallbackCategory,
            slot: Slot.accessory.name,
            isBuiltIn: const Value(true),
            sortOrder: Value(order++),
          ),
        ],
        mode: InsertMode.insertOrIgnore,
      );

      order = 0;
      b.insertAll(
        occasions,
        [
          for (final (name, formality) in CatalogSeed.occasions)
            OccasionsCompanion.insert(
              name: name,
              formality: Value(formality),
              isBuiltIn: const Value(true),
              sortOrder: Value(order++),
            ),
        ],
        mode: InsertMode.insertOrIgnore,
      );

      order = 0;
      b.insertAll(
        moods,
        [
          for (final name in CatalogSeed.moods)
            MoodsCompanion.insert(
              name: name,
              isBuiltIn: const Value(true),
              sortOrder: Value(order++),
            ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}
