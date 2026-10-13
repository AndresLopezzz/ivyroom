import 'dart:math';

import '../color/color_theory.dart';
import '../models/catalog.dart';
import '../models/garment.dart';
import '../models/outfit.dart';
import 'wear_history.dart';

/// Contrato del generador de outfits.
///
/// Existe como interfaz para poder enchufar mas adelante una implementacion
/// basada en IA sin tocar ni una pantalla.
abstract class OutfitEngine {
  /// [history] es lo que ya se ha llevado puesto y cuando. Se pasa aparte
  /// del armario porque es estado del mundo, no una preferencia: el motor lo
  /// usa para no proponer lo mismo dos veces seguidas.
  List<OutfitSuggestion> generate(
    List<Garment> wardrobe,
    OutfitRequest req, {
    WearHistory history,
  });

  /// Puntua un conjunto concreto de prendas, sin generar nada.
  ///
  /// Es lo que permite que el creador manual de outfits ensene en vivo si lo
  /// que el usuario esta eligiendo combina, reutilizando exactamente las
  /// mismas reglas que las sugerencias automaticas.
  OutfitSuggestion scoreOne(
    List<Garment> items, {
    OutfitRequest? req,
    WearHistory history,
  });
}

/// Plantilla de composicion: que ranuras lleva un outfit.
class _Template {
  const _Template(this.required, this.optional, this.label);
  final List<Slot> required;
  final List<Slot> optional;
  final String label;
}

const _templates = <_Template>[
  _Template([Slot.top, Slot.bottom, Slot.shoes], [Slot.outer, Slot.accessory],
      'conjunto clásico'),
  _Template([Slot.dress, Slot.shoes], [Slot.outer, Slot.accessory], 'vestido'),
];

/// Motor determinista basado en teoria del color y tags.
///
/// No hace I/O y no depende de Flutter: se puede probar entero con
/// `dart test`.
class RuleOutfitEngine implements OutfitEngine {
  const RuleOutfitEngine({
    this.maxCombinations = 4000,
    this.now,
  });

  /// Techo de combinaciones evaluadas. Con armarios grandes el producto
  /// cartesiano explota, asi que se muestrea en vez de enumerar todo.
  final int maxCombinations;

  /// Inyectable para que los tests controlen "hoy".
  final DateTime Function()? now;

  @override
  List<OutfitSuggestion> generate(
    List<Garment> wardrobe,
    OutfitRequest req, {
    WearHistory history = WearHistory.empty,
  }) {
    // El dia relevante es aquel para el que se pide, no siempre hoy: al
    // planificar la semana, el lunes que viene se juzga como lunes.
    final today = req.forDay ?? (now ?? DateTime.now)();
    final pool = _filter(wardrobe, req);

    final bySlot = <Slot, List<Garment>>{};
    for (final g in pool) {
      bySlot.putIfAbsent(g.slot, () => []).add(g);
    }

    final rng = Random(req.seed);
    final seen = <String>{};
    final out = <OutfitSuggestion>[];
    var budget = maxCombinations;

    for (final tpl in _templates) {
      // Plantilla inviable si falta cualquier ranura obligatoria.
      if (tpl.required.any((s) => (bySlot[s] ?? const []).isEmpty)) continue;

      // Si el usuario fija una prenda, solo sirven las plantillas que tengan
      // su ranura.
      final must = req.mustInclude;
      if (must != null &&
          !tpl.required.contains(must.slot) &&
          !tpl.optional.contains(must.slot)) {
        continue;
      }

      final tries = _triesFor(tpl, bySlot, budget);
      budget -= tries;

      for (var i = 0; i < tries; i++) {
        final items = <Garment>[];

        for (final slot in tpl.required) {
          final candidates = bySlot[slot]!;
          if (must != null && must.slot == slot) {
            items.add(must);
          } else {
            items.add(candidates[rng.nextInt(candidates.length)]);
          }
        }

        // Las opcionales entran segun lo que pida el clima y el azar.
        for (final slot in tpl.optional) {
          final candidates = bySlot[slot] ?? const <Garment>[];
          if (candidates.isEmpty) continue;
          if (must != null && must.slot == slot) {
            items.add(must);
            continue;
          }
          final p = slot == Slot.outer ? _outerProbability(req.tempC) : 0.4;
          if (rng.nextDouble() < p) {
            items.add(candidates[rng.nextInt(candidates.length)]);
          }
        }

        if (must != null && !items.contains(must)) continue;

        final ids = items.map((g) => g.id).toSet();
        if (ids.length != items.length) continue; // prenda duplicada
        final key = (ids.toList()..sort()).join('-');
        if (!seen.add(key)) continue;

        out.add(_score(items, req, today, tpl.label, history));
      }
      if (budget <= 0) break;
    }

    out.sort((a, b) => b.score.compareTo(a.score));
    return out.take(req.count).toList();
  }

  @override
  OutfitSuggestion scoreOne(
    List<Garment> items, {
    OutfitRequest? req,
    WearHistory history = WearHistory.empty,
  }) {
    final request = req ?? const OutfitRequest();
    final today = request.forDay ?? (now ?? DateTime.now)();
    return _score(items, request, today, _labelFor(items), history);
  }

  /// Etiqueta la composicion de un conjunto ya armado, que puede no
  /// corresponder a ninguna plantilla si el usuario lo monto a mano.
  String _labelFor(List<Garment> items) {
    final slots = items.map((g) => g.slot).toSet();
    if (slots.contains(Slot.dress)) return 'vestido';
    if (slots.containsAll({Slot.top, Slot.bottom, Slot.shoes})) {
      return 'conjunto clásico';
    }
    return 'combinación libre';
  }

  // ---- filtrado ----------------------------------------------------------

  List<Garment> _filter(List<Garment> wardrobe, OutfitRequest req) {
    return wardrobe.where((g) {
      if (g.isArchived) return false;

      // Una prenda sin temporada/ocasion declarada se considera comodin: no
      // se descarta por no haberla etiquetado.
      if (req.season != null &&
          g.seasons.isNotEmpty &&
          !g.seasons.contains(req.season)) {
        return false;
      }
      if (req.occasion != null &&
          g.occasions.isNotEmpty &&
          !g.occasions.contains(req.occasion)) {
        return false;
      }

      // El clima descarta lo claramente inadecuado; el matiz lo pone la
      // puntuacion, no el filtro.
      final t = req.tempC;
      if (t != null) {
        if (t >= 26 && g.category.warmth >= 4) return false;
        if (t <= 5 && g.category.warmth == 0) return false;
      }
      return true;
    }).toList();
  }

  /// Cuantas combinaciones muestrear para esta plantilla, acotado por el
  /// tamano real del espacio de busqueda.
  int _triesFor(_Template tpl, Map<Slot, List<Garment>> bySlot, int budget) {
    var space = 1;
    for (final s in tpl.required) {
      space *= (bySlot[s] ?? const []).length;
      if (space > budget) return budget;
    }
    // Un factor extra por las opcionales, para no quedarse corto de variedad.
    return min(budget, max(20, space * 3));
  }

  /// Probabilidad de anadir una capa de abrigo segun la temperatura.
  double _outerProbability(double? tempC) {
    if (tempC == null) return 0.35;
    if (tempC <= 5) return 0.98;
    if (tempC <= 12) return 0.85;
    if (tempC <= 18) return 0.5;
    if (tempC <= 24) return 0.15;
    return 0.0;
  }

  // ---- puntuacion --------------------------------------------------------

  OutfitSuggestion _score(
    List<Garment> items,
    OutfitRequest req,
    DateTime today,
    String templateLabel,
    WearHistory history,
  ) {
    final reasons = <String>[templateLabel];
    var total = 0.0;

    total += _colorScore(items, reasons) * 3.0;
    total += _contrastScore(items, reasons) * 1.0;
    total += _occasionScore(items, req, reasons) * 2.0;
    total += _weatherScore(items, req, reasons) * 1.5;
    total += _moodScore(items, req, reasons) * 1.5;
    total += _noveltyScore(items, req, today, reasons) * 1.0;
    total += _repetitionScore(items, req, today, history, reasons) * 2.0;
    total += _favoriteBonus(items) * 0.5;

    // Normalizado a [0, 1] sobre la suma de pesos.
    const weightSum = 3.0 + 1.0 + 2.0 + 1.5 + 1.5 + 1.0 + 2.0 + 0.5;
    return OutfitSuggestion(
      items: items,
      score: total / weightSum,
      reasons: reasons,
    );
  }

  /// Media de armonia entre todos los pares, mas una penalizacion si hay
  /// demasiados colores saturados peleandose.
  double _colorScore(List<Garment> items, List<String> reasons) {
    final colors = items.map((g) => g.color).toList();
    if (colors.length < 2) return 0.8;

    var sum = 0.0;
    var pairs = 0;
    Harmony? worst;
    Harmony? best;

    for (var i = 0; i < colors.length; i++) {
      for (var j = i + 1; j < colors.length; j++) {
        final h = harmonyBetween(colors[i], colors[j]);
        sum += h.score;
        pairs++;
        if (worst == null || h.score < worst.score) worst = h;
        if (best == null || h.score > best.score) best = h;
      }
    }

    var score = sum / pairs;

    final loud = colors.where((c) => !c.isNeutral && c.s > 0.55).length;
    if (loud > 2) {
      score *= 0.6;
      reasons.add('$loud colores fuertes a la vez, arriesgado');
    }

    // Se reporta la relacion dominante: la peor si algo chirria, la mejor si
    // todo encaja.
    if (worst != null && worst.score < 0.5) {
      reasons.add(worst.reason);
    } else if (best != null && best != Harmony.neutralPair) {
      reasons.add(best.reason);
    } else {
      reasons.add(Harmony.neutralPair.reason);
    }

    return score;
  }

  double _contrastScore(List<Garment> items, List<String> reasons) {
    final top = _firstWithSlot(items, Slot.top);
    final bottom = _firstWithSlot(items, Slot.bottom);
    if (top == null || bottom == null) return 0.8;

    final s = lightnessContrastScore(top.color.l, bottom.color.l);
    if (s < 0.5) reasons.add('poco contraste entre arriba y abajo');
    return s;
  }

  double _occasionScore(
      List<Garment> items, OutfitRequest req, List<String> reasons) {
    final target = req.occasion?.formality;
    if (target == null) {
      // Sin ocasion pedida se premia la coherencia interna: que no haya
      // tacones con pantalon de chandal.
      final f = items.map((g) => g.category.formality).toList();
      final spread = f.reduce(max) - f.reduce(min);
      if (spread >= 3) {
        reasons.add('mezcla de registros muy dispares');
        return 0.35;
      }
      return spread >= 2 ? 0.7 : 1.0;
    }

    final avg = items.map((g) => g.category.formality).reduce((a, b) => a + b) /
        items.length;
    final diff = (avg - target).abs();
    if (diff <= 0.5) {
      reasons.add('encaja con ${req.occasion!.name}');
      return 1.0;
    }
    if (diff <= 1.2) return 0.7;
    reasons.add('formalidad algo fuera de ${req.occasion!.name}');
    return 0.3;
  }

  double _weatherScore(
      List<Garment> items, OutfitRequest req, List<String> reasons) {
    final t = req.tempC;
    if (t == null) return 0.8;

    final total = items.map((g) => g.category.warmth).reduce((a, b) => a + b);
    // Abrigo objetivo aproximado: ~10 puntos a 0 grados, ~2 a 30 grados.
    final target = (10 - (t * 0.27)).clamp(1.0, 11.0);
    final diff = (total - target).abs();

    if (diff <= 2) {
      reasons.add('adecuado para ${t.round()} grados');
      return 1.0;
    }
    if (diff <= 4) return 0.6;
    reasons.add(total < target
        ? 'te quedarías corto de abrigo'
        : 'demasiado abrigo para ${t.round()} grados');
    return 0.2;
  }

  double _moodScore(
      List<Garment> items, OutfitRequest req, List<String> reasons) {
    final mood = req.mood;
    if (mood == null) return 0.8;

    final tagged = items.where((g) => g.moods.isNotEmpty).toList();
    if (tagged.isEmpty) return 0.5;

    final hits = tagged.where((g) => g.moods.contains(mood)).length;
    final ratio = hits / tagged.length;
    if (ratio >= 0.6) reasons.add('mood ${mood.name}');
    return ratio;
  }

  /// Penaliza repetir lo recien puesto, para que el armario rote.
  double _noveltyScore(List<Garment> items, OutfitRequest req, DateTime today,
      List<String> reasons) {
    if (req.avoidRecentDays <= 0) return 1.0;

    var worst = 1.0;
    for (final g in items) {
      final worn = g.lastWornAt;
      if (worn == null) continue;
      final days = today.difference(worn).inDays;
      if (days < req.avoidRecentDays) {
        final penalty = days / req.avoidRecentDays;
        if (penalty < worst) worst = penalty;
      }
    }
    if (worst < 0.4) reasons.add('incluye algo puesto hace poco');
    return worst;
  }

  /// Penaliza repetir el mismo conjunto exacto.
  ///
  /// Separado de la novedad por prenda: reutilizar un jean en varios outfits
  /// es normal y deseable, repetir el conjunto entero al poco es lo que se
  /// nota. Y repetirlo el mismo dia de la semana es lo que mas se nota de
  /// todo, porque lo ve la misma gente en el mismo sitio.
  double _repetitionScore(
    List<Garment> items,
    OutfitRequest req,
    DateTime today,
    WearHistory history,
    List<String> reasons,
  ) {
    if (history.entries.isEmpty) return 1.0;
    final ids = items.map((g) => g.id);

    var score = 1.0;

    final sinceWeekday = req.avoidSameWeekdayDays <= 0
        ? null
        : history.daysSinceComboOnWeekday(ids, today.weekday, today);
    if (sinceWeekday != null && sinceWeekday < req.avoidSameWeekdayDays) {
      score *= (sinceWeekday / req.avoidSameWeekdayDays).clamp(0.15, 1.0);
      reasons.add('ya lo llevaste otro ${_weekdayName(today.weekday)}');
    }

    final since = req.avoidRepeatDays <= 0
        ? null
        : history.daysSinceCombo(ids, today);
    if (since != null && since < req.avoidRepeatDays) {
      score *= (since / req.avoidRepeatDays).clamp(0.1, 1.0);
      if (sinceWeekday == null || sinceWeekday != since) {
        reasons.add(since == 0
            ? 'lo llevaste hoy mismo'
            : 'lo llevaste hace $since ${since == 1 ? 'día' : 'días'}');
      }
    }

    return score;
  }

  static const _weekdays = [
    'lunes', 'martes', 'miércoles', 'jueves',
    'viernes', 'sábado', 'domingo',
  ];

  String _weekdayName(int weekday) =>
      _weekdays[(weekday - 1).clamp(0, 6)];

  double _favoriteBonus(List<Garment> items) {
    final favs = items.where((g) => g.isFavorite).length;
    return items.isEmpty ? 0 : favs / items.length;
  }

  Garment? _firstWithSlot(List<Garment> items, Slot slot) {
    for (final g in items) {
      if (g.slot == slot) return g;
    }
    return null;
  }
}
