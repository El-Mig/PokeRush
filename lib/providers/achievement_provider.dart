import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final bool isUnlocked;

  Achievement({
    required this.id,
    this.isUnlocked = false,
  });

  Achievement copyWith({bool? isUnlocked}) {
    return Achievement(
      id: id,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class AchievementNotifier extends StateNotifier<List<Achievement>> {
  AchievementNotifier() : super(_initialAchievements) {
    _loadAchievements();
  }

  static final List<Achievement> _initialAchievements = [
    Achievement(id: 'first_win'),
    Achievement(id: 'gen1_master'),
    Achievement(id: 'shiny_found'),
    Achievement(id: 'survival_pro'),
    Achievement(id: 'velocista'),
    Achievement(id: 'racha_bronce'),
    Achievement(id: 'racha_plata'),
    Achievement(id: 'racha_oro'),
    Achievement(id: 'intocable'),
    Achievement(id: 'maestro_elemental'),
    Achievement(id: 'explorador_johto'),
    Achievement(id: 'leyenda_hoenn'),
    Achievement(id: 'especialista'),
    Achievement(id: 'dios_supervivencia'),
    Achievement(id: 'a_contrarreloj'),
    Achievement(id: 'cazador_shinies'),
    Achievement(id: 'dia_suerte'),
    Achievement(id: 'buho_nocturno'),
    Achievement(id: 'madrugador'),
  ];

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.map((a) {
      return a.copyWith(isUnlocked: prefs.getBool('ach_${a.id}') ?? false);
    }).toList();
  }

  Future<void> unlock(String id) async {
    final index = state.indexWhere((a) => a.id == id);
    if (index != -1 && !state[index].isUnlocked) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ach_$id', true);

      final newList = [...state];
      newList[index] = newList[index].copyWith(isUnlocked: true);
      state = newList;
    }
  }
}

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, List<Achievement>>((ref) {
  return AchievementNotifier();
});
