import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameMode { classic, survival }

class SettingsState {
  final GameMode gameMode;
  final bool dynamicBackgrounds;
  final double correctAngle; // Negative (e.g., -6.0)
  final double skipAngle; // Positive (e.g., 8.5)

  SettingsState({
    this.gameMode = GameMode.classic,
    this.dynamicBackgrounds = true,
    this.correctAngle = -6.0,
    this.skipAngle = 8.5,
  });

  SettingsState copyWith({
    GameMode? gameMode,
    bool? dynamicBackgrounds,
    double? correctAngle,
    double? skipAngle,
  }) {
    return SettingsState(
      gameMode: gameMode ?? this.gameMode,
      dynamicBackgrounds: dynamicBackgrounds ?? this.dynamicBackgrounds,
      correctAngle: correctAngle ?? this.correctAngle,
      skipAngle: skipAngle ?? this.skipAngle,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      gameMode: GameMode.values[prefs.getInt('gameMode') ?? 0],
      dynamicBackgrounds: prefs.getBool('dynamicBackgrounds') ?? true,
      correctAngle: prefs.getDouble('correctAngle') ?? -6.0,
      skipAngle: prefs.getDouble('skipAngle') ?? 8.5,
    );
  }

  Future<void> setGameMode(GameMode mode) async {
    state = state.copyWith(gameMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gameMode', mode.index);
  }

  Future<void> toggleDynamicBackgrounds(bool value) async {
    state = state.copyWith(dynamicBackgrounds: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dynamicBackgrounds', value);
  }

  Future<void> setAngles(double correct, double skip) async {
    state = state.copyWith(correctAngle: correct, skipAngle: skip);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('correctAngle', correct);
    await prefs.setDouble('skipAngle', skip);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
