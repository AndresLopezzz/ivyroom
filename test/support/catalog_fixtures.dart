import 'package:ivyroom/domain/models/catalog.dart';
import 'package:ivyroom/domain/models/garment.dart';

/// Catálogo de prueba.
///
/// Desde que categoría, ocasión y mood son datos y no enums, los tests del
/// dominio necesitan construirlos. Se hace aquí, con ids fijos, para que los
/// tests hablen de "una camiseta" y no de la fontanería de crear catálogos.
class Cat {
  const Cat._();

  static const tshirt =
      Category(id: 1, name: 'Camiseta', slot: Slot.top, formality: 1, warmth: 1);
  static const shirt =
      Category(id: 2, name: 'Camisa', slot: Slot.top, formality: 3, warmth: 1);
  static const sweater =
      Category(id: 3, name: 'Suéter', slot: Slot.top, formality: 2, warmth: 3);
  static const hoodie =
      Category(id: 4, name: 'Buzo', slot: Slot.top, formality: 1, warmth: 3);

  static const jeans = Category(
      id: 10, name: 'Jean', slot: Slot.bottom, formality: 2, warmth: 2);
  static const trousers = Category(
      id: 11, name: 'Pantalón', slot: Slot.bottom, formality: 3, warmth: 2);
  static const shorts = Category(
      id: 12, name: 'Short', slot: Slot.bottom, formality: 1, warmth: 0);
  static const joggers = Category(
      id: 13,
      name: 'Pantalón deportivo',
      slot: Slot.bottom,
      formality: 1,
      warmth: 2);

  static const dress = Category(
      id: 20, name: 'Vestido', slot: Slot.dress, formality: 4, warmth: 1);

  static const jacket = Category(
      id: 30, name: 'Chaqueta', slot: Slot.outer, formality: 3, warmth: 3);
  static const coat = Category(
      id: 31, name: 'Abrigo', slot: Slot.outer, formality: 4, warmth: 4);
  static const blazer = Category(
      id: 32, name: 'Blazer', slot: Slot.outer, formality: 4, warmth: 2);

  static const sneakers = Category(
      id: 40, name: 'Tenis', slot: Slot.shoes, formality: 1, warmth: 1);
  static const heels = Category(
      id: 41, name: 'Tacones', slot: Slot.shoes, formality: 4, warmth: 1);
  static const flats = Category(
      id: 42, name: 'Baletas', slot: Slot.shoes, formality: 3, warmth: 1);
  static const boots = Category(
      id: 43, name: 'Botas', slot: Slot.shoes, formality: 3, warmth: 3);
  static const sandals = Category(
      id: 44, name: 'Sandalias', slot: Slot.shoes, formality: 1, warmth: 0);
}

class Occ {
  const Occ._();
  static const casual = Occasion(id: 1, name: 'Casual', formality: 1);
  static const work = Occasion(id: 2, name: 'Trabajo', formality: 3);
  static const formal = Occasion(id: 3, name: 'Formal', formality: 4);
  static const sport = Occasion(id: 5, name: 'Deporte', formality: 0);
}

class Wash {
  const Wash._();
  static const oscuros = WashGroup(id: 1, name: 'Oscuros');
  static const normal = WashGroup(id: 2, name: 'Normal');
  static const pesada = WashGroup(id: 3, name: 'Ropa pesada');
}

class Md {
  const Md._();
  static const chill = Mood(id: 1, name: 'Relajado');
  static const elegant = Mood(id: 3, name: 'Elegante');
  static const playful = Mood(id: 4, name: 'Divertido');
}

const black = 0xFF1A1A1A;
const white = 0xFFF2F2F2;
const grey = 0xFF808080;
const blue = 0xFF1E5ADC;
const orange = 0xFFE6821E;
const red = 0xFFDC1E1E;
const green = 0xFF28B43C;

/// Contador de ids para las prendas de prueba. Se reinicia en cada test para
/// que los conjuntos comparados entre ejecuciones sean equivalentes.
int _nextId = 1;
void resetGarmentIds() => _nextId = 1;

Garment garment(
  Category category,
  int argb, {
  Set<Season> seasons = const {},
  Set<Occasion> occasions = const {},
  Set<Mood> moods = const {},
  DateTime? lastWorn,
  int wearCount = 0,
  int washCount = 0,
  DateTime? lastWashed,
  WashGroup? washGroup,
  bool favorite = false,
  bool archived = false,
  DateTime? createdAt,
}) {
  final id = _nextId++;
  return Garment(
    id: id,
    imagePath: 'garments/g$id.png',
    thumbPath: 'garments/g${id}_thumb.png',
    category: category,
    dominantColorArgb: argb,
    seasons: seasons,
    occasions: occasions,
    moods: moods,
    lastWornAt: lastWorn,
    wearCount: wearCount,
    washCount: washCount,
    lastWashedAt: lastWashed,
    washGroup: washGroup,
    isFavorite: favorite,
    isArchived: archived,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}
