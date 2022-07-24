const String tableTransectPoint = 'TRANSECT_POINT';

class TransectPointFields {
  static const String id = '_id';
  static const String species = 'species';
  static const String soil = 'soil';
  static const String mulch = 'mulch';
  static const String rock = 'rock';
  static const String stone = 'stone';
  static const String annotations = 'annotations';
  static const String created = 'created_date';
  static const String mark = 'mark_time';
  static const String hits = 'hits';
  static const String areaId = 'area_id';
  static const String teamId = 'team_id';

  static final List<String> values = [
    id,
    species,
    soil,
    mulch,
    rock,
    stone,
    annotations,
    created,
    mark,
    hits,
    areaId,
    teamId,
  ];
}

class TransectPoint {
  final int? id;
  final String? species;
  final bool? soil;
  final bool? mulch;
  final bool? rock;
  final bool? stone;
  final String? annotations;
  final DateTime created;
  final DateTime mark;
  final int hits;
  final int areaId;
  final int teamId;

  const TransectPoint({
    this.id,
    this.species,
    this.soil,
    this.mulch,
    this.rock,
    this.stone,
    this.annotations,
    required this.created,
    required this.mark,
    required this.hits,
    required this.areaId,
    required this.teamId,
  });

  TransectPoint copy({
    int? id,
    String? species,
    bool? soil,
    bool? mulch,
    bool? rock,
    bool? stone,
    String? annotations,
    DateTime? created,
    DateTime? mark,
    int? hits,
    int? areaId,
    int? teamId,
  }) =>
      TransectPoint(
        id: id ?? this.id,
        species: species ?? this.species,
        soil: soil ?? this.soil,
        mulch: mulch ?? this.mulch,
        rock: rock ?? this.rock,
        stone: stone ?? this.stone,
        annotations: annotations ?? this.annotations,
        created: created ?? this.created,
        mark: mark ?? this.mark,
        hits: hits ?? this.hits,
        areaId: areaId ?? this.areaId,
        teamId: teamId ?? this.teamId,
      );

  static TransectPoint fromJSON(Map<String, Object?> json) => TransectPoint(
        id: json[TransectPointFields.id] as int?,
        species: json[TransectPointFields.species] as String,
        soil: json[TransectPointFields.soil] == 1,
        mulch: json[TransectPointFields.mulch] == 1,
        rock: json[TransectPointFields.rock] == 1,
        stone: json[TransectPointFields.stone] == 1,
        annotations: json[TransectPointFields.annotations] as String,
        created: DateTime.parse(json[TransectPointFields.created] as String),
        mark: DateTime.parse(json[TransectPointFields.mark] as String),
        hits: json[TransectPointFields.hits] as int,
        areaId: json[TransectPointFields.areaId] as int,
        teamId: json[TransectPointFields.teamId] as int,
      );

  Map<String, Object?> toJSON() => {
        TransectPointFields.id: id,
        TransectPointFields.species: species,
        TransectPointFields.soil: soil! ? 1 : 0,
        TransectPointFields.mulch: mulch! ? 1 : 0,
        TransectPointFields.rock: rock! ? 1 : 0,
        TransectPointFields.stone: stone! ? 1 : 0,
        TransectPointFields.annotations: annotations,
        TransectPointFields.created: created.toIso8601String(),
        TransectPointFields.mark: mark.toIso8601String(),
        TransectPointFields.hits: hits,
        TransectPointFields.areaId: areaId,
        TransectPointFields.teamId: teamId,
      };
}
