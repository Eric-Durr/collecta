const String tableSimpleSpecies = 'SPECIES_NAME';

class SimpleSpeciesFields {
  static const String id = 'id';
  static const String name = 'name';

  static final List<String> values = [
    id,
    name,
  ];
}

class SimpleSpecies {
  final int? id;
  final String name;

  const SimpleSpecies({
    this.id,
    required this.name,
  });

  SimpleSpecies copy({
    int? id,
    String? name,
  }) =>
      SimpleSpecies(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  static SimpleSpecies fromJSON(Map<String, Object?> json) => SimpleSpecies(
        id: json[SimpleSpeciesFields.id] as int?,
        name: json[SimpleSpeciesFields.name] as String,
      );

  Map<String, Object?> toJSON() => {
        SimpleSpeciesFields.id: id,
        SimpleSpeciesFields.name: name,
      };
}
