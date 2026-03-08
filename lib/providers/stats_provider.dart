import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStats {
  final int totalGames;
  final int totalCorrect;
  final int totalShinies;
  final int bestStreak;

  UserStats({
    this.totalGames = 0,
    this.totalCorrect = 0,
    this.totalShinies = 0,
    this.bestStreak = 0,
  });

  UserStats copyWith({
    int? totalGames,
    int? totalCorrect,
    int? totalShinies,
    int? bestStreak,
  }) {
    return UserStats(
      totalGames: totalGames ?? this.totalGames,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalShinies: totalShinies ?? this.totalShinies,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }
}

class StatsNotifier extends StateNotifier<UserStats> {
  StatsNotifier() : super(UserStats()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserStats(
      totalGames: prefs.getInt('stats_total_games') ?? 0,
      totalCorrect: prefs.getInt('stats_total_correct') ?? 0,
      totalShinies: prefs.getInt('stats_total_shinies') ?? 0,
      bestStreak: prefs.getInt('stats_best_streak') ?? 0,
    );
  }

  Future<void> addGame() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = state.totalGames + 1;
    await prefs.setInt('stats_total_games', newVal);
    state = state.copyWith(totalGames: newVal);
  }

  Future<void> addCorrect(bool isShiny, int currentStreak) async {
    final prefs = await SharedPreferences.getInstance();

    int newCorrect = state.totalCorrect + 1;
    int newShinies = state.totalShinies + (isShiny ? 1 : 0);
    int newBestStreak =
        currentStreak > state.bestStreak ? currentStreak : state.bestStreak;

    await prefs.setInt('stats_total_correct', newCorrect);
    await prefs.setInt('stats_total_shinies', newShinies);
    await prefs.setInt('stats_best_streak', newBestStreak);

    state = state.copyWith(
      totalCorrect: newCorrect,
      totalShinies: newShinies,
      bestStreak: newBestStreak,
    );
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, UserStats>((ref) {
  return StatsNotifier();
});
