import 'package:flutter/material.dart';

enum CropGroup { leafy, brassica, root, fruit, vine, allium, herb, flower }

class CropKind {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final CropGroup group;
  final int daysToHarvest;
  final bool startIndoor;
  final String companion;
  final String sowWindow;

  const CropKind(
    this.id,
    this.name,
    this.emoji,
    this.color, {
    this.group = CropGroup.leafy,
    this.daysToHarvest = 50,
    this.startIndoor = false,
    this.companion = '',
    this.sowWindow = 'Spring',
  });

  bool get isEmpty => id == 'empty';

  String get groupLabel => switch (group) {
        CropGroup.leafy => 'Leafy',
        CropGroup.brassica => 'Brassica',
        CropGroup.root => 'Roots',
        CropGroup.fruit => 'Fruiting',
        CropGroup.vine => 'Vines',
        CropGroup.allium => 'Allium',
        CropGroup.herb => 'Herbs',
        CropGroup.flower => 'Flowers',
      };

  static const empty = CropKind(
    'empty',
    'Empty',
    '·',
    Color(0xFFC4A574),
    group: CropGroup.leafy,
    daysToHarvest: 0,
    companion: 'Tap a square to plant. Leave one fallow to rest the soil.',
  );

  static const lettuce = CropKind('lettuce', 'Lettuce', '🥬', Color(0xFF6FBF73), daysToHarvest: 45, startIndoor: true, companion: 'Lettuce likes shade from taller tomatoes.', sowWindow: 'Mar – Sep');
  static const spinach = CropKind('spinach', 'Spinach', '🌿', Color(0xFF3D8B4A), daysToHarvest: 40, companion: 'Spinach bolts in heat — sow with peas for cool cover.', sowWindow: 'Feb – Apr');
  static const kale = CropKind('kale', 'Kale', '🥬', Color(0xFF2F7A45), group: CropGroup.brassica, daysToHarvest: 60, startIndoor: true, companion: 'Kale pairs with onions to deter cabbage moths.', sowWindow: 'Mar – Aug');
  static const chard = CropKind('chard', 'Chard', '🍃', Color(0xFF4C9A5C), daysToHarvest: 55, companion: 'Chard is happy beside beans and onions.', sowWindow: 'Mar – Jul');
  static const arugula = CropKind('arugula', 'Arugula', '🥗', Color(0xFF6FAF62), daysToHarvest: 30, companion: 'Quick arugula fills gaps beside slower brassicas.', sowWindow: 'Mar – Sep');
  static const cabbage = CropKind('cabbage', 'Cabbage', '🥬', Color(0xFF5BA86A), group: CropGroup.brassica, daysToHarvest: 80, startIndoor: true, companion: 'Dill and onions help keep cabbage worms off.', sowWindow: 'Mar – Jun');
  static const bokChoy = CropKind('bokchoy', 'Bok choy', '🥬', Color(0xFF7BCF7A), group: CropGroup.brassica, daysToHarvest: 45, companion: 'Bok choy likes beets and garlic nearby.', sowWindow: 'Mar – May');
  static const broccoli = CropKind('broccoli', 'Broccoli', '🥦', Color(0xFF3D8B4A), group: CropGroup.brassica, daysToHarvest: 80, startIndoor: true, companion: 'Celery and onions are classic broccoli neighbors.', sowWindow: 'Mar – Jul');
  static const cauliflower = CropKind('cauliflower', 'Cauliflower', '🤍', Color(0xFF8FBF8A), group: CropGroup.brassica, daysToHarvest: 85, startIndoor: true, companion: 'Keep cauliflower with herbs that confuse moths.', sowWindow: 'Mar – Jun');

  static const radish = CropKind('radish', 'Radishes', '🌸', Color(0xFFE07A9A), group: CropGroup.root, daysToHarvest: 28, companion: 'Radishes mark slow carrot rows and break crust.', sowWindow: 'Mar – Sep');
  static const carrot = CropKind('carrot', 'Carrots', '🥕', Color(0xFFE07A3D), group: CropGroup.root, daysToHarvest: 70, companion: 'Onions confuse carrot fly. Avoid planting near dill.', sowWindow: 'Mar – Jul');
  static const beet = CropKind('beet', 'Beets', '🟥', Color(0xFFB8445A), group: CropGroup.root, daysToHarvest: 55, companion: 'Beets grow well with lettuce, onions, and cabbage.', sowWindow: 'Mar – Jul');
  static const potato = CropKind('potato', 'Potatoes', '🥔', Color(0xFFC4A574), group: CropGroup.root, daysToHarvest: 90, companion: 'Beans feed potatoes. Keep them away from tomatoes.', sowWindow: 'Mar – May');
  static const turnip = CropKind('turnip', 'Turnips', '⚪', Color(0xFFB8C4A8), group: CropGroup.root, daysToHarvest: 50, companion: 'Turnips like peas and mint as neighbors.', sowWindow: 'Mar – Aug');
  static const parsnip = CropKind('parsnip', 'Parsnip', '🪵', Color(0xFFD4B896), group: CropGroup.root, daysToHarvest: 110, companion: 'Parsnip is slow — interplant radish to mark the row.', sowWindow: 'Mar – May');
  static const sweetPotato = CropKind('sweetpotato', 'Sweet potato', '🍠', Color(0xFFD4783C), group: CropGroup.root, daysToHarvest: 100, startIndoor: true, companion: 'Give sweet potato room; basil nearby helps pests.', sowWindow: 'May – Jun');

  static const tomato = CropKind('tomato', 'Tomatoes', '🍅', Color(0xFFD94A4A), group: CropGroup.fruit, daysToHarvest: 75, startIndoor: true, companion: 'Basil and marigold beside tomatoes help flavor and pests.', sowWindow: 'Mar – May');
  static const pepper = CropKind('pepper', 'Peppers', '🫑', Color(0xFF2E9A62), group: CropGroup.fruit, daysToHarvest: 70, startIndoor: true, companion: 'Peppers like basil, onions, and carrots nearby.', sowWindow: 'Mar – May');
  static const chili = CropKind('chili', 'Chili', '🌶️', Color(0xFFE85D3D), group: CropGroup.fruit, daysToHarvest: 80, startIndoor: true, companion: 'Chili enjoys the same companions as sweet peppers.', sowWindow: 'Mar – May');
  static const eggplant = CropKind('eggplant', 'Eggplant', '🍆', Color(0xFF7A4EA8), group: CropGroup.fruit, daysToHarvest: 80, startIndoor: true, companion: 'Thyme and beans are good eggplant neighbors.', sowWindow: 'Mar – May');
  static const cucumber = CropKind('cucumber', 'Cucumber', '🥒', Color(0xFF4CAF6A), group: CropGroup.vine, daysToHarvest: 55, startIndoor: true, companion: 'Nasturtium and beans help cucumber beetles.', sowWindow: 'Apr – Jun');
  static const zucchini = CropKind('zucchini', 'Zucchini', '🟢', Color(0xFF5BBF4A), group: CropGroup.fruit, daysToHarvest: 50, companion: 'Zucchini likes nasturtium and corn at the edge.', sowWindow: 'Apr – Jun');
  static const squash = CropKind('squash', 'Squash', '🎃', Color(0xFFE8A03A), group: CropGroup.fruit, daysToHarvest: 90, companion: 'Corn, beans, and squash are the three sisters.', sowWindow: 'May – Jun');
  static const pumpkin = CropKind('pumpkin', 'Pumpkin', '🎃', Color(0xFFE07A3D), group: CropGroup.fruit, daysToHarvest: 100, companion: 'Give pumpkin a trail; marigolds at the start help.', sowWindow: 'May – Jun');
  static const corn = CropKind('corn', 'Corn', '🌽', Color(0xFFE8B84A), group: CropGroup.fruit, daysToHarvest: 80, companion: 'Corn shelters beans; squash shades the soil.', sowWindow: 'Apr – Jun');
  static const okra = CropKind('okra', 'Okra', '🫒', Color(0xFF6B8F3A), group: CropGroup.fruit, daysToHarvest: 60, companion: 'Okra likes peppers and basil in the same bed.', sowWindow: 'May – Jun');

  static const pea = CropKind('pea', 'Peas', '🟢', Color(0xFF7BCF6A), group: CropGroup.vine, daysToHarvest: 60, companion: 'Peas fix nitrogen for leafy greens that follow.', sowWindow: 'Feb – Apr');
  static const bean = CropKind('bean', 'Beans', '🫘', Color(0xFF6B4F32), group: CropGroup.vine, daysToHarvest: 55, companion: 'Beans feed corn and cucumbers. Skip onions beside them.', sowWindow: 'Apr – Jul');
  static const watermelon = CropKind('watermelon', 'Watermelon', '🍉', Color(0xFF2E9A62), group: CropGroup.vine, daysToHarvest: 85, companion: 'Sunflowers can trellis melon vines at the bed edge.', sowWindow: 'May – Jun');
  static const melon = CropKind('melon', 'Melon', '🍈', Color(0xFFC4D46A), group: CropGroup.vine, daysToHarvest: 80, companion: 'Melons like radish and marigold at the border.', sowWindow: 'May – Jun');
  static const strawberry = CropKind('strawberry', 'Strawberry', '🍓', Color(0xFFD94A4A), group: CropGroup.vine, daysToHarvest: 90, companion: 'Borage and lettuce are kind strawberry neighbors.', sowWindow: 'Mar – Apr');

  static const onion = CropKind('onion', 'Onions', '🧅', Color(0xFFC4A574), group: CropGroup.allium, daysToHarvest: 100, companion: 'Onions deter pests around carrots, beets, and brassicas.', sowWindow: 'Feb – Apr');
  static const garlic = CropKind('garlic', 'Garlic', '🧄', Color(0xFFE8D4A8), group: CropGroup.allium, daysToHarvest: 240, companion: 'Garlic planted in autumn guards tomatoes next year.', sowWindow: 'Oct – Nov');
  static const leek = CropKind('leek', 'Leeks', '🌱', Color(0xFF7BA86A), group: CropGroup.allium, daysToHarvest: 120, startIndoor: true, companion: 'Leeks pair with carrots and celery.', sowWindow: 'Feb – Apr');
  static const scallion = CropKind('scallion', 'Scallions', '🌱', Color(0xFF5A8F6C), group: CropGroup.allium, daysToHarvest: 40, companion: 'Scallions tuck into gaps beside lettuce and radish.', sowWindow: 'Mar – Sep');
  static const shallot = CropKind('shallot', 'Shallots', '🧅', Color(0xFFB07A8A), group: CropGroup.allium, daysToHarvest: 90, companion: 'Shallots like beets and avoid peas and beans.', sowWindow: 'Feb – Mar');

  static const basil = CropKind('basil', 'Basil', '🌱', Color(0xFF2E9A62), group: CropGroup.herb, daysToHarvest: 40, startIndoor: true, companion: 'Basil beside tomatoes is the classic pairing.', sowWindow: 'Apr – Jun');
  static const parsley = CropKind('parsley', 'Parsley', '🌿', Color(0xFF3D8B4A), group: CropGroup.herb, daysToHarvest: 70, startIndoor: true, companion: 'Parsley helps tomatoes and asparagus edges.', sowWindow: 'Mar – Jun');
  static const cilantro = CropKind('cilantro', 'Cilantro', '🌿', Color(0xFF5A8F6C), group: CropGroup.herb, daysToHarvest: 35, companion: 'Cilantro flowers feed hoverflies that eat aphids.', sowWindow: 'Mar – May');
  static const mint = CropKind('mint', 'Mint', '🍃', Color(0xFF2E9A62), group: CropGroup.herb, daysToHarvest: 30, companion: 'Keep mint in a pot — it crowds beds but deters pests.', sowWindow: 'Apr – Jun');
  static const rosemary = CropKind('rosemary', 'Rosemary', '🌲', Color(0xFF3D6B4C), group: CropGroup.herb, daysToHarvest: 90, startIndoor: true, companion: 'Rosemary likes sage and beans, dislikes cucumbers.', sowWindow: 'Mar – May');
  static const thyme = CropKind('thyme', 'Thyme', '🌿', Color(0xFF6B8F5A), group: CropGroup.herb, daysToHarvest: 80, companion: 'Thyme at bed edges helps cabbage and eggplant.', sowWindow: 'Mar – May');
  static const oregano = CropKind('oregano', 'Oregano', '🌿', Color(0xFF4C7A3A), group: CropGroup.herb, daysToHarvest: 80, companion: 'Oregano is a general pest-confused border herb.', sowWindow: 'Apr – Jun');
  static const dill = CropKind('dill', 'Dill', '🌾', Color(0xFFC4D46A), group: CropGroup.herb, daysToHarvest: 40, companion: 'Dill helps brassicas. Keep it off carrots.', sowWindow: 'Apr – Jul');
  static const sage = CropKind('sage', 'Sage', '🍃', Color(0xFF7BA86A), group: CropGroup.herb, daysToHarvest: 75, companion: 'Sage with rosemary and cabbage, not cucumbers.', sowWindow: 'Mar – May');
  static const chives = CropKind('chives', 'Chives', '🌱', Color(0xFF5A8F6C), group: CropGroup.herb, daysToHarvest: 60, companion: 'Chives deter aphids around lettuce and carrots.', sowWindow: 'Mar – May');

  static const marigold = CropKind('marigold', 'Marigold', '🌼', Color(0xFFE8B84A), group: CropGroup.flower, daysToHarvest: 50, companion: 'Marigolds help repel nematodes and keep tomatoes happier.', sowWindow: 'Apr – Jun');
  static const sunflower = CropKind('sunflower', 'Sunflower', '🌻', Color(0xFFE8B84A), group: CropGroup.flower, daysToHarvest: 80, companion: 'Sunflowers can trellis beans and shade lettuce.', sowWindow: 'Apr – Jun');
  static const nasturtium = CropKind('nasturtium', 'Nasturtium', '🌺', Color(0xFFE07A3D), group: CropGroup.flower, daysToHarvest: 45, companion: 'Nasturtium is a trap crop for aphids near squash.', sowWindow: 'Apr – Jul');
  static const lavender = CropKind('lavender', 'Lavender', '💜', Color(0xFF7B6CF6), group: CropGroup.flower, daysToHarvest: 90, companion: 'Lavender at the path draws pollinators to fruiting crops.', sowWindow: 'Mar – May');
  static const borage = CropKind('borage', 'Borage', '🔵', Color(0xFF4A8FD4), group: CropGroup.flower, daysToHarvest: 55, companion: 'Borage boosts strawberries and tomato pollination.', sowWindow: 'Apr – Jun');

  static const List<CropKind> plantable = [
    lettuce, spinach, kale, chard, arugula, cabbage, bokChoy, broccoli, cauliflower,
    radish, carrot, beet, potato, turnip, parsnip, sweetPotato,
    tomato, pepper, chili, eggplant, cucumber, zucchini, squash, pumpkin, corn, okra,
    pea, bean, watermelon, melon, strawberry,
    onion, garlic, leek, scallion, shallot,
    basil, parsley, cilantro, mint, rosemary, thyme, oregano, dill, sage, chives,
    marigold, sunflower, nasturtium, lavender, borage,
  ];

  static const List<CropKind> all = [empty, ...plantable];

  static List<CropGroup> get groups => CropGroup.values;

  static CropKind byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return lettuce;
  }

  static String companionForBed(Iterable<BedCell> cells) {
    final crops = cells.map((c) => c.crop).where((c) => !c.isEmpty).toList();
    if (crops.isEmpty) return empty.companion;
    for (final c in crops) {
      if (c.group == CropGroup.flower) return c.companion;
    }
    return crops.first.companion;
  }
}

class BedCell {
  final String cropId;
  const BedCell({required this.cropId});

  CropKind get crop => CropKind.byId(cropId);

  Map<String, dynamic> toJson() => {'cropId': cropId};
  factory BedCell.fromJson(Map<String, dynamic> json) => BedCell(cropId: json['cropId']?.toString() ?? 'lettuce');

  BedCell copyWith({String? cropId}) => BedCell(cropId: cropId ?? this.cropId);
}

class GardenBed {
  final String id;
  final String name;
  final int rows;
  final int cols;
  final List<BedCell> cells;
  final String notes;
  final String companionHint;

  const GardenBed({
    required this.id,
    required this.name,
    required this.cells,
    this.rows = 3,
    this.cols = 3,
    this.notes = '',
    this.companionHint = '',
  });

  int get cellCount => rows * cols;

  String get layoutLabel => '${rows}×$cols';

  BedCell cellAt(int r, int c) {
    final i = r * cols + c;
    if (i < 0 || i >= cells.length) return const BedCell(cropId: 'empty');
    return cells[i];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rows': rows,
        'cols': cols,
        'cells': cells.map((c) => c.toJson()).toList(),
        'notes': notes,
        'companionHint': companionHint,
      };

  factory GardenBed.fromJson(Map<String, dynamic> json) {
    final raw = json['cells'] as List<dynamic>? ?? [];
    final parsed = raw.map((e) => BedCell.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    final inferred = BedLayout.infer(parsed.length);
    final rows = (json['rows'] as num?)?.toInt() ?? inferred.rows;
    final cols = (json['cols'] as num?)?.toInt() ?? inferred.cols;
    return GardenBed(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Bed',
      rows: rows.clamp(1, 6),
      cols: cols.clamp(1, 6),
      cells: BedLayout.fitCells(parsed, rows.clamp(1, 6), cols.clamp(1, 6)),
      notes: json['notes']?.toString() ?? '',
      companionHint: json['companionHint']?.toString() ?? '',
    );
  }

  GardenBed copyWith({
    List<BedCell>? cells,
    String? notes,
    String? name,
    int? rows,
    int? cols,
    String? companionHint,
  }) =>
      GardenBed(
        id: id,
        name: name ?? this.name,
        rows: rows ?? this.rows,
        cols: cols ?? this.cols,
        cells: cells ?? this.cells,
        notes: notes ?? this.notes,
        companionHint: companionHint ?? this.companionHint,
      );
}

class BedLayout {
  final String id;
  final String name;
  final String blurb;
  final int rows;
  final int cols;

  const BedLayout(this.id, this.name, this.blurb, this.rows, this.cols);

  int get cellCount => rows * cols;
  String get sizeLabel => '${rows}×$cols';

  static const herbPot = BedLayout('2x2', 'Herb pot', 'Four squares for kitchen herbs', 2, 2);
  static const raised = BedLayout('3x3', 'Raised bed', 'Classic nine-square plot', 3, 3);
  static const kitchen = BedLayout('4x4', 'Kitchen plot', 'Sixteen squares for a full mix', 4, 4);
  static const rowBed = BedLayout('2x4', 'Row bed', 'Wide two-row sowing strip', 2, 4);
  static const longBed = BedLayout('3x4', 'Long bed', 'Three rows, extra columns', 3, 4);
  static const pathBed = BedLayout('4x2', 'Path bed', 'Tall bed along a walkway', 4, 2);
  static const border = BedLayout('1x6', 'Border strip', 'Single row along the fence', 1, 6);

  static const List<BedLayout> all = [herbPot, raised, kitchen, rowBed, longBed, pathBed, border];

  static BedLayout matching(int rows, int cols) {
    for (final l in all) {
      if (l.rows == rows && l.cols == cols) return l;
    }
    return BedLayout('custom', 'Custom', '$rows×$cols', rows, cols);
  }

  static BedLayout infer(int cellCount) {
    for (final l in all) {
      if (l.cellCount == cellCount) return l;
    }
    if (cellCount <= 0) return raised;
    final side = cellCount <= 4 ? 2 : cellCount <= 9 ? 3 : 4;
    return BedLayout('inferred', 'Bed', '${side}×$side', side, side);
  }

  static List<BedCell> emptyCells(int rows, int cols) =>
      List.generate(rows * cols, (_) => const BedCell(cropId: 'empty'));

  static List<BedCell> fitCells(List<BedCell> old, int newRows, int newCols, {int oldRows = 0, int oldCols = 0}) {
    var or = oldRows;
    var oc = oldCols;
    if (or <= 0 || oc <= 0) {
      final inferred = infer(old.length);
      or = inferred.rows;
      oc = inferred.cols;
    }
    return [
      for (var r = 0; r < newRows; r++)
        for (var c = 0; c < newCols; c++)
          (r < or && c < oc && r * oc + c < old.length) ? old[r * oc + c] : const BedCell(cropId: 'empty'),
    ];
  }
}

class PlantingTask {
  final String id;
  final String title;
  final String cropId;
  final String place;
  final DateTime due;
  final bool indoor;
  final bool done;

  const PlantingTask({
    required this.id,
    required this.title,
    required this.cropId,
    required this.place,
    required this.due,
    this.indoor = false,
    this.done = false,
  });

  CropKind get crop => CropKind.byId(cropId);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'cropId': cropId,
        'place': place,
        'due': due.toIso8601String(),
        'indoor': indoor,
        'done': done,
      };

  factory PlantingTask.fromJson(Map<String, dynamic> json) => PlantingTask(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        cropId: json['cropId']?.toString() ?? 'lettuce',
        place: json['place']?.toString() ?? '',
        due: DateTime.tryParse(json['due']?.toString() ?? '') ?? DateTime.now(),
        indoor: json['indoor'] == true,
        done: json['done'] == true,
      );

  PlantingTask copyWith({bool? done, DateTime? due, String? title, String? place}) => PlantingTask(
        id: id,
        title: title ?? this.title,
        cropId: cropId,
        place: place ?? this.place,
        due: due ?? this.due,
        indoor: indoor,
        done: done ?? this.done,
      );
}

class SeedLot {
  final String id;
  final String cropId;
  final String variety;
  final double grams;
  final double price;
  final DateTime? lastSown;

  const SeedLot({
    required this.id,
    required this.cropId,
    required this.variety,
    required this.grams,
    required this.price,
    this.lastSown,
  });

  CropKind get crop => CropKind.byId(cropId);

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropId': cropId,
        'variety': variety,
        'grams': grams,
        'price': price,
        'lastSown': lastSown?.toIso8601String(),
      };

  factory SeedLot.fromJson(Map<String, dynamic> json) => SeedLot(
        id: json['id']?.toString() ?? '',
        cropId: json['cropId']?.toString() ?? 'lettuce',
        variety: json['variety']?.toString() ?? '',
        grams: (json['grams'] as num?)?.toDouble() ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        lastSown: DateTime.tryParse(json['lastSown']?.toString() ?? ''),
      );
}

class SupplyItem {
  final String id;
  final String name;
  final String qty;
  const SupplyItem({required this.id, required this.name, required this.qty});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'qty': qty};
  factory SupplyItem.fromJson(Map<String, dynamic> json) => SupplyItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        qty: json['qty']?.toString() ?? '',
      );
}

class HarvestEntry {
  final String id;
  final String cropId;
  final String variety;
  final double kg;
  final double value;
  final DateTime date;

  const HarvestEntry({
    required this.id,
    required this.cropId,
    required this.variety,
    required this.kg,
    required this.value,
    required this.date,
  });

  CropKind get crop => CropKind.byId(cropId);

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropId': cropId,
        'variety': variety,
        'kg': kg,
        'value': value,
        'date': date.toIso8601String(),
      };

  factory HarvestEntry.fromJson(Map<String, dynamic> json) => HarvestEntry(
        id: json['id']?.toString() ?? '',
        cropId: json['cropId']?.toString() ?? 'lettuce',
        variety: json['variety']?.toString() ?? '',
        kg: (json['kg'] as num?)?.toDouble() ?? 0,
        value: (json['value'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      );
}

class JournalNote {
  final String id;
  final String title;
  final String body;
  final DateTime at;
  const JournalNote({required this.id, required this.title, required this.body, required this.at});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body, 'at': at.toIso8601String()};
  factory JournalNote.fromJson(Map<String, dynamic> json) => JournalNote(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        at: DateTime.tryParse(json['at']?.toString() ?? '') ?? DateTime.now(),
      );
}
