import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameMode { classic, survival }

class SettingsState {
  final GameMode gameMode;
  final bool dynamicBackgrounds;
  final double correctAngle; // Negative (e.g., -6.0)
  final double skipAngle; // Positive (e.g., 8.5)
  final String locale; // 'es' or 'en'
  final String trainerName;
  final int avatarIndex;
  final String? avatarPath;

  SettingsState({
    this.gameMode = GameMode.classic,
    this.dynamicBackgrounds = true,
    this.correctAngle = -6.0,
    this.skipAngle = 8.5,
    this.locale = 'es',
    this.trainerName = 'ENTRENADOR',
    this.avatarIndex = 0,
    this.avatarPath,
  });

  SettingsState copyWith({
    GameMode? gameMode,
    bool? dynamicBackgrounds,
    double? correctAngle,
    double? skipAngle,
    String? locale,
    String? trainerName,
    int? avatarIndex,
    String? avatarPath,
    bool clearAvatarPath = false,
  }) {
    return SettingsState(
      gameMode: gameMode ?? this.gameMode,
      dynamicBackgrounds: dynamicBackgrounds ?? this.dynamicBackgrounds,
      correctAngle: correctAngle ?? this.correctAngle,
      skipAngle: skipAngle ?? this.skipAngle,
      locale: locale ?? this.locale,
      trainerName: trainerName ?? this.trainerName,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      avatarPath: clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
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
      locale: prefs.getString('locale') ?? 'es',
      trainerName: prefs.getString('trainerName') ?? 'ENTRENADOR',
      avatarIndex: prefs.getInt('avatarIndex') ?? 0,
      avatarPath: prefs.getString('avatarPath'),
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

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
  }

  Future<void> setTrainerName(String name) async {
    state = state.copyWith(trainerName: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trainerName', name);
  }

  Future<void> setAvatarIndex(int index) async {
    state = state.copyWith(avatarIndex: index, clearAvatarPath: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('avatarIndex', index);
    await prefs.remove('avatarPath');
  }

  Future<void> setAvatarPath(String? path) async {
    try {
      state = state.copyWith(avatarPath: path, clearAvatarPath: path == null);
      final prefs = await SharedPreferences.getInstance();
      if (path != null) {
        await prefs.setString('avatarPath', path);
      } else {
        await prefs.remove('avatarPath');
      }
    } catch (e) {
      // Catch storage limits on Web
      print("Error saving avatar: $e");
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
