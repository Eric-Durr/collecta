const String tableMeasureArea = 'MEASURE_AREA';

class MeasureAreaFields {
  static const String id = '_id';
  static const String lat = 'latitude';
  static const String lon = 'longitude';
  static const String annotations = 'annotations';
  static const String uTMZone = 'UTM_zone';
  static const String geographicSystem = 'geographic_system';
  static const String projectId = 'project_id';

  static final List<String> values = [
    id,
    lat,
    lon,
    annotations,
    uTMZone,
    geographicSystem,
    projectId
  ];
}

class MeasureArea {
  final int? id;
  final String lat;
  final String lon;
  final String annotations;
  final String uTMZone;
  final String geographicSystem;
  final int projectId;

  const MeasureArea({
    this.id,
    required this.lat,
    required this.lon,
    required this.uTMZone,
    required this.annotations,
    required this.geographicSystem,
    required this.projectId,
  });

  MeasureArea copy({
    int? id,
    String? lat,
    String? lon,
    String? annotations,
    String? uTMZone,
    String? geographicSystem,
    int? projectId,
  }) =>
      MeasureArea(
        id: id ?? this.id,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        annotations: annotations ?? this.annotations,
        uTMZone: uTMZone ?? this.uTMZone,
        geographicSystem: geographicSystem ?? this.geographicSystem,
        projectId: projectId ?? this.projectId,
      );

  static MeasureArea fromJSON(Map<String, Object?> json) => MeasureArea(
        id: json[MeasureAreaFields.id] as int?,
        lat: json[MeasureAreaFields.lat] as String,
        lon: json[MeasureAreaFields.lon] as String,
        annotations: json[MeasureAreaFields.annotations] as String,
        uTMZone: json[MeasureAreaFields.uTMZone] as String,
        geographicSystem: json[MeasureAreaFields.geographicSystem] as String,
        projectId: json[MeasureAreaFields.projectId] as int,
      );

  Map<String, Object?> toJSON() => {
        MeasureAreaFields.id: id,
        MeasureAreaFields.lat: lat,
        MeasureAreaFields.lon: lon,
        MeasureAreaFields.annotations: annotations,
        MeasureAreaFields.uTMZone: uTMZone,
        MeasureAreaFields.geographicSystem: geographicSystem,
        MeasureAreaFields.projectId: projectId,
      };
}
