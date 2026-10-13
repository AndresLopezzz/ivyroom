/// Lo que se ha llevado puesto y cuándo.
///
/// Es la memoria del motor. Sin ella no hay forma de contestar a "no me
/// propongas otra vez lo del lunes pasado", que es justo lo que convierte
/// una lista de sugerencias en algo que se puede seguir día a día.
library;

/// Una salida concreta: qué se llevó puesto un día.
class WearEntry {
  const WearEntry({
    required this.day,
    required this.garmentIds,
    this.outfitId,
  });

  /// Normalizado a medianoche.
  final DateTime day;

  final Set<int> garmentIds;

  /// El outfit guardado del que salió, si vino de uno.
  final int? outfitId;

  /// Clave del conjunto, para comparar combinaciones sin depender del orden.
  String get key => comboKey(garmentIds);
}

/// Clave estable de un conjunto de prendas.
String comboKey(Iterable<int> garmentIds) {
  final ids = garmentIds.toList()..sort();
  return ids.join('-');
}

class WearHistory {
  WearHistory(List<WearEntry> entries)
      : _byKey = _index(entries),
        _all = List.unmodifiable(entries);

  static const empty = WearHistory._empty();

  const WearHistory._empty()
      : _byKey = const {},
        _all = const [];

  final Map<String, List<WearEntry>> _byKey;
  final List<WearEntry> _all;

  List<WearEntry> get entries => _all;

  static Map<String, List<WearEntry>> _index(List<WearEntry> entries) {
    final out = <String, List<WearEntry>>{};
    for (final e in entries) {
      out.putIfAbsent(e.key, () => []).add(e);
    }
    // Cada lista de más reciente a más antigua: casi siempre solo interesa
    // la última.
    for (final list in out.values) {
      list.sort((a, b) => b.day.compareTo(a.day));
    }
    return out;
  }

  static DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Días desde la última vez que se llevó este conjunto exacto, o null si
  /// nunca se ha llevado.
  int? daysSinceCombo(Iterable<int> garmentIds, DateTime today) {
    final list = _byKey[comboKey(garmentIds)];
    if (list == null || list.isEmpty) return null;
    return _midnight(today).difference(_midnight(list.first.day)).inDays;
  }

  /// Días desde la última vez que se llevó este conjunto **en este mismo día
  /// de la semana**.
  ///
  /// Ponerse lo mismo dos lunes seguidos se nota mucho más que ponérselo un
  /// lunes y un jueves: lo ve la misma gente en el mismo contexto.
  int? daysSinceComboOnWeekday(
      Iterable<int> garmentIds, int weekday, DateTime today) {
    final list = _byKey[comboKey(garmentIds)];
    if (list == null) return null;
    for (final e in list) {
      if (e.day.weekday == weekday) {
        return _midnight(today).difference(_midnight(e.day)).inDays;
      }
    }
    return null;
  }

  /// Cuántas veces se ha llevado este conjunto.
  int timesWorn(Iterable<int> garmentIds) =>
      _byKey[comboKey(garmentIds)]?.length ?? 0;
}
