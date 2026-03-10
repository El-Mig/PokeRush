import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_score.dart';

class MultiplayerState {
  final List<PlayerScore> players;
  final int currentPlayerIndex;
  final bool isActive;

  MultiplayerState({
    required this.players,
    this.currentPlayerIndex = 0,
    this.isActive = false,
  });

  MultiplayerState copyWith({
    List<PlayerScore>? players,
    int? currentPlayerIndex,
    bool? isActive,
  }) {
    return MultiplayerState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      isActive: isActive ?? this.isActive,
    );
  }

  PlayerScore? get currentPlayer {
    if (players.isEmpty || currentPlayerIndex >= players.length) return null;
    return players[currentPlayerIndex];
  }

  bool get isLastPlayer => currentPlayerIndex == players.length - 1;
}

class MultiplayerNotifier extends StateNotifier<MultiplayerState> {
  MultiplayerNotifier() : super(MultiplayerState(players: []));

  void startTournament(List<String> playerNames) {
    if (playerNames.length < 2) return;

    final players = playerNames.map((name) => PlayerScore(name: name)).toList();
    state = MultiplayerState(
      players: players,
      isActive: true,
      currentPlayerIndex: 0,
    );
  }

  void recordTurnResults({
    required int score,
    required List<String> correctPokemon,
    required List<String> skippedPokemon,
  }) {
    if (!state.isActive || state.players.isEmpty) return;

    final updatedPlayers = List<PlayerScore>.from(state.players);
    updatedPlayers[state.currentPlayerIndex] =
        updatedPlayers[state.currentPlayerIndex].copyWith(
      score: score,
      correctPokemon: correctPokemon,
      skippedPokemon: skippedPokemon,
    );

    state = state.copyWith(players: updatedPlayers);
  }

  void nextTurn() {
    if (!state.isActive || state.isLastPlayer) return;

    state = state.copyWith(
      currentPlayerIndex: state.currentPlayerIndex + 1,
    );
  }

  void finishTournament() {
    state = state.copyWith(isActive: false);
  }

  void reset() {
    state = MultiplayerState(players: []);
  }
}

final multiplayerProvider =
    StateNotifierProvider<MultiplayerNotifier, MultiplayerState>((ref) {
  return MultiplayerNotifier();
});
