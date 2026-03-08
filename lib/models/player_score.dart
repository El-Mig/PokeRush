class PlayerScore {
  final String name;
  final int score;
  final List<String> correctPokemon;
  final List<String> skippedPokemon;
  final String? assignedColor; // Hex string, e.g., '#F7D02C'

  PlayerScore({
    required this.name,
    this.score = 0,
    this.correctPokemon = const [],
    this.skippedPokemon = const [],
    this.assignedColor,
  });

  PlayerScore copyWith({
    String? name,
    int? score,
    List<String>? correctPokemon,
    List<String>? skippedPokemon,
    String? assignedColor,
  }) {
    return PlayerScore(
      name: name ?? this.name,
      score: score ?? this.score,
      correctPokemon: correctPokemon ?? this.correctPokemon,
      skippedPokemon: skippedPokemon ?? this.skippedPokemon,
      assignedColor: assignedColor ?? this.assignedColor,
    );
  }
}
