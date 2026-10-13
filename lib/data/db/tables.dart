import 'package:drift/drift.dart';

// ---- catálogos editables ---------------------------------------------------

/// Tipos de prenda. Editables por el usuario, pero SIEMPRE atados a un slot:
/// sin ranura el motor de outfits no sabría dónde colocar la prenda.
@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();

  /// Nombre del valor de `Slot`. Obligatorio.
  TextColumn get slot => text()();

  IntColumn get formality => integer().withDefault(const Constant(2))();
  IntColumn get warmth => integer().withDefault(const Constant(1))();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('OccasionRow')
class Occasions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get formality => integer().withDefault(const Constant(2))();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('MoodRow')
class Moods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Grupo de lavado: con qué carga va la prenda a la lavadora.
@DataClassName('WashGroupRow')
class WashGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Tag libre. `name` único para no duplicar.
@DataClassName('TagRow')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

// ---- prendas ---------------------------------------------------------------

@DataClassName('GarmentRow')
class Garments extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Rutas RELATIVAS al directorio de documentos de la app. En Android la
  /// ruta absoluta del sandbox cambia entre reinstalaciones y
  /// actualizaciones, así que guardar la absoluta rompería las imágenes.
  TextColumn get imagePath => text()();
  TextColumn get thumbPath => text()();

  /// La foto sin recortar, por si se quiere rehacer el recorte.
  TextColumn get originalPath => text().nullable()();

  /// Sin `onDelete: cascade` a propósito: borrar una categoría no debe
  /// borrar la ropa. El repositorio reasigna las prendas a "Sin clasificar".
  IntColumn get categoryId => integer().references(Categories, #id)();

  IntColumn get dominantColorArgb => integer()();

  /// Familia cromática derivada del ARGB y persistida.
  ///
  /// Es dato derivado, que normalmente no se guarda. Aquí sí, porque es la
  /// única forma de que el filtro por color se resuelva en SQL como todos
  /// los demás en vez de traer el armario entero y descartar en memoria.
  TextColumn get colorFamily => text()();

  /// Paleta secundaria como JSON de enteros ARGB. Es informativa y no se
  /// filtra por ella, así que un blob JSON basta.
  TextColumn get paletteJson => text().withDefault(const Constant('[]'))();

  TextColumn get name => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// Sin cascade: borrar un grupo de lavado no puede borrar ropa. Las
  /// prendas se quedan sin clasificar y ya.
  IntColumn get washGroupId => integer()
      .nullable()
      .references(WashGroups, #id, onDelete: KeyAction.setNull)();

  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get wearCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWornAt => dateTime().nullable()();

  /// Lavadas acumuladas: la métrica de desgaste que de verdad importa.
  IntColumn get washCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWashedAt => dateTime().nullable()();

  /// Usos desde la última lavada. Se pone a cero al lavar.
  IntColumn get wearsSinceWash => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
}

/// Un día de lavado. Un día, una entrada.
@DataClassName('LaundryDayRow')
class LaundryDays extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Dia normalizado a medianoche. Es la clave: un dia, una lavada.
  DateTimeColumn get day => dateTime().unique()();

  /// Momento real de la lavada, con hora.
  ///
  /// Separado de [day] porque comparar contra medianoche daba un falso
  /// positivo en el caso mas comun: te pones algo por la manana, lo lavas
  /// esa tarde, y la prenda seguia saliendo como sucia porque su hora de
  /// uso era posterior a las 00:00 del dia de lavado.
  ///
  /// No lleva default a proposito: siempre se escribe explicitamente. La
  /// migracion que anadio esta columna recrea la tabla en vez de usar
  /// ALTER ADD COLUMN, porque SQLite no acepta anadir una columna NOT NULL
  /// sin default ni con un default no constante.
  DateTimeColumn get washedAt => dateTime()();

  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class LaundryItems extends Table {
  IntColumn get laundryDayId =>
      integer().references(LaundryDays, #id, onDelete: KeyAction.cascade)();
  IntColumn get garmentId =>
      integer().references(Garments, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {laundryDayId, garmentId};
}

// ---- tablas puente ---------------------------------------------------------

class GarmentTags extends Table {
  IntColumn get garmentId =>
      integer().references(Garments, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {garmentId, tagId};
}

/// La temporada sigue siendo un enum cerrado: son cuatro y no cambian.
class GarmentSeasons extends Table {
  IntColumn get garmentId =>
      integer().references(Garments, #id, onDelete: KeyAction.cascade)();
  TextColumn get season => text()();

  @override
  Set<Column> get primaryKey => {garmentId, season};
}

/// Aquí sí hay cascade en ambos lados: si el usuario borra la ocasión
/// "Universidad", las prendas se quedan pero dejan de estar etiquetadas con
/// ella, que es exactamente lo que espera.
class GarmentOccasions extends Table {
  IntColumn get garmentId =>
      integer().references(Garments, #id, onDelete: KeyAction.cascade)();
  IntColumn get occasionId =>
      integer().references(Occasions, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {garmentId, occasionId};
}

class GarmentMoods extends Table {
  IntColumn get garmentId =>
      integer().references(Garments, #id, onDelete: KeyAction.cascade)();
  IntColumn get moodId =>
      integer().references(Moods, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {garmentId, moodId};
}

// ---- outfits ---------------------------------------------------------------

@DataClassName('OutfitRow')
class Outfits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  IntColumn get occasionId =>
      integer().nullable().references(Occasions, #id, onDelete: KeyAction.setNull)();
  IntColumn get moodId =>
      integer().nullable().references(Moods, #id, onDelete: KeyAction.setNull)();
  TextColumn get notes => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get wearCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWornAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Que se piensa poner el usuario un dia concreto.
///
/// Un plan puede apuntar a un outfit guardado o llevar sus propias prendas
/// sueltas: obligar a guardar un outfit solo para planificar un martes seria
/// friccion tonta.
@DataClassName('PlanRow')
class OutfitPlans extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Dia planificado, normalizado a medianoche. NO es unico: un dia admite
  /// varias opciones, y al llegar el dia se marca cual se llevo de verdad.
  /// Planificar es barajar alternativas, no comprometerse a una.
  DateTimeColumn get day => dateTime()();

  IntColumn get outfitId => integer()
      .nullable()
      .references(Outfits, #id, onDelete: KeyAction.setNull)();

  TextColumn get notes => text().nullable()();

  /// Se marca cuando el usuario confirma que se lo puso de verdad. Sin esto
  /// no habria forma de distinguir "lo tenia planeado" de "me lo puse".
  BoolColumn get wasWorn => boolean().withDefault(const Constant(false))();

  /// Foto del look puesto (del espejo), relativa como las de las prendas.
  /// Convierte el calendario en un diario de lo que se llevo.
  TextColumn get photoPath => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}

/// Prendas sueltas de un plan que no viene de un outfit guardado.
class PlanItems extends Table {
  IntColumn get planId =>
      integer().references(OutfitPlans, #id, onDelete: KeyAction.cascade)();
  IntColumn get garmentId =>
      integer().references(Garments, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {planId, garmentId};
}

class OutfitItems extends Table {
  IntColumn get outfitId =>
      integer().references(Outfits, #id, onDelete: KeyAction.cascade)();
  IntColumn get garmentId =>
      integer().references(Garments, #id, onDelete: KeyAction.cascade)();

  /// Ranura congelada en el momento de guardar: si más adelante se
  /// recategoriza la prenda, el outfit guardado conserva su composición.
  TextColumn get slot => text()();

  @override
  Set<Column> get primaryKey => {outfitId, garmentId};
}
