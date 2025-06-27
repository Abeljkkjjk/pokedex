class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  final List<String> abilities;
  final Map<String, int> stats;
  bool isFavorite;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
    this.isFavorite = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ?? 
                json['sprites']['front_default'] ?? '',
      types: (json['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList(),
      height: json['height'],
      weight: json['weight'],
      abilities: (json['abilities'] as List)
          .map((ability) => ability['ability']['name'] as String)
          .toList(),
      stats: Map.fromEntries(
        (json['stats'] as List).map(
          (stat) => MapEntry(
            stat['stat']['name'] as String,
            stat['base_stat'] as int,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'types': types.join(','),
      'height': height,
      'weight': weight,
      'abilities': abilities.join(','),
      'stats': stats.entries
          .map((e) => '${e.key}:${e.value}')
          .join(','),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    final statsMap = <String, int>{};
    final statsString = map['stats'] as String;
    for (final stat in statsString.split(',')) {
      final parts = stat.split(':');
      if (parts.length == 2) {
        statsMap[parts[0]] = int.parse(parts[1]);
      }
    }

    return Pokemon(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      types: (map['types'] as String).split(','),
      height: map['height'],
      weight: map['weight'],
      abilities: (map['abilities'] as String).split(','),
      stats: statsMap,
      isFavorite: map['isFavorite'] == 1,
    );
  }
}