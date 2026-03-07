class Pokemon {
  final int id;
  final String name;
  final String spriteUrl;
  final String shinySpriteUrl;
  final List<String> types;
  final bool isShiny;

  Pokemon({
    required this.id,
    required this.name,
    required this.spriteUrl,
    required this.shinySpriteUrl,
    required this.types,
    this.isShiny = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json, {bool isShiny = false}) {
    final name = (json['name'] as String).toUpperCase();
    var typesList = json['types'] as List;
    List<String> types = typesList
        .map((t) => (t['type']['name'] as String).toUpperCase())
        .toList();

    return Pokemon(
      id: json['id'],
      name: name,
      spriteUrl: json['sprites']['front_default'] ?? '',
      shinySpriteUrl: json['sprites']['front_shiny'] ?? '',
      types: types,
      isShiny: isShiny,
    );
  }

  String get currentSpriteUrl => isShiny ? shinySpriteUrl : spriteUrl;

  String get generationText {
    if (id <= 151) return 'GEN 1';
    if (id <= 251) return 'GEN 2';
    if (id <= 386) return 'GEN 3';
    if (id <= 493) return 'GEN 4';
    if (id <= 649) return 'GEN 5';
    if (id <= 721) return 'GEN 6';
    if (id <= 809) return 'GEN 7';
    if (id <= 905) return 'GEN 8';
    if (id <= 1025) return 'GEN 9';
    return 'GEN ?';
  }
}
