import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pokemon_service.dart';
import 'game_provider.dart';

final cacheProvider = StateNotifierProvider<CacheNotifier, CacheState>((ref) {
  final pokemonService = ref.read(pokemonServiceProvider);
  return CacheNotifier(pokemonService);
});

class CacheState {
  final bool isDownloading;
  final int currentProgress;
  final int totalItemCount;
  final String? errorMessage;
  final bool isComplete;

  CacheState({
    required this.isDownloading,
    required this.currentProgress,
    required this.totalItemCount,
    this.errorMessage,
    this.isComplete = false,
  });

  CacheState copyWith({
    bool? isDownloading,
    int? currentProgress,
    int? totalItemCount,
    String? errorMessage,
    bool? isComplete,
  }) {
    return CacheState(
      isDownloading: isDownloading ?? this.isDownloading,
      currentProgress: currentProgress ?? this.currentProgress,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      errorMessage: errorMessage,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class CacheNotifier extends StateNotifier<CacheState> {
  final PokemonService _pokemonService;

  CacheNotifier(this._pokemonService)
      : super(CacheState(
          isDownloading: false,
          currentProgress: 0,
          totalItemCount: 1025, // PokeAPI total default for general use
        ));

  Future<void> downloadEntirePokedex() async {
    if (state.isDownloading) return;

    state = state.copyWith(
        isDownloading: true, errorMessage: null, isComplete: false);

    try {
      await _pokemonService.downloadEntirePokedex(
        (current, total) {
          if (mounted) {
            state = state.copyWith(
              currentProgress: current,
              totalItemCount: total,
            );
          }
        },
      );

      if (mounted) {
        state = state.copyWith(
          isDownloading: false,
          isComplete: true,
          currentProgress: state.totalItemCount, // Force to 100% just in case
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isDownloading: false,
          errorMessage: e.toString(),
        );
      }
    }
  }
}
