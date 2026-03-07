import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.isUnlocked = false,
  });

  Achievement copyWith({bool? isUnlocked}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class AchievementNotifier extends StateNotifier<List<Achievement>> {
  AchievementNotifier() : super(_initialAchievements) {
    _loadAchievements();
  }

  static final List<Achievement> _initialAchievements = [
    Achievement(
        id: 'first_win',
        title: 'Novato',
        description: 'Adivina tu primer Pokémon'),
    Achievement(
        id: 'gen1_master',
        title: 'Maestro de Kanto',
        description: 'Adivina 50 Pokémon de la Gen 1'),
    Achievement(
      id: 'shiny_found',
      title: '¡Shiny Encontrado!',
      description: 'Encuentra un Pokémon variocolor.',
    ),
    Achievement(
      id: 'survival_pro',
      title: 'Pro en Supervivencia',
      description: 'Aguanta más de 2 minutos en modo supervivencia.',
    ),
    Achievement(
      id: 'velocista',
      title: 'Velocista',
      description: 'Acierta 10 Pokémon en menos de 30 segundos.',
    ),
    Achievement(
      id: 'racha_bronce',
      title: 'Racha de Bronce',
      description: '10 aciertos seguidos sin saltar ninguno.',
    ),
    Achievement(
      id: 'racha_plata',
      title: 'Racha de Plata',
      description: '25 aciertos seguidos.',
    ),
    Achievement(
      id: 'racha_oro',
      title: 'Racha de Oro',
      description: '50 aciertos seguidos.',
    ),
    Achievement(
      id: 'intocable',
      title: 'Intocable',
      description: 'Termina una partida clásica sin usar "Paso".',
    ),
    Achievement(
      id: 'maestro_elemental',
      title: 'Maestro Elemental',
      description: 'Acierta un Pokémon de cada tipo en una sesión.',
    ),
    Achievement(
      id: 'explorador_johto',
      title: 'Explorador Johto',
      description: 'Acierta 50 Pokémon de la Gen 2.',
    ),
    Achievement(
      id: 'leyenda_hoenn',
      title: 'Leyenda de Hoenn',
      description: 'Acierta 50 Pokémon de la Gen 3.',
    ),
    Achievement(
      id: 'especialista',
      title: 'Especialista',
      description: 'Acierta 20 Pokémon de un mismo tipo en una partida.',
    ),
    Achievement(
      id: 'dios_supervivencia',
      title: 'Dios de la Supervivencia',
      description: 'Aguanta 5 minutos en modo Supervivencia.',
    ),
    Achievement(
      id: 'a_contrarreloj',
      title: 'A Contrarreloj',
      description: 'Acierta cuando queden menos de 5 segundos.',
    ),
    Achievement(
      id: 'cazador_shinies',
      title: 'Cazador de Shinies',
      description: 'Encuentra 5 Pokémon Shiny en total.',
    ),
    Achievement(
      id: 'dia_suerte',
      title: 'Día de Suerte',
      description: 'Encuentra 2 Shinies en una misma partida.',
    ),
    Achievement(
      id: 'buho_nocturno',
      title: 'Búho Nocturno',
      description: 'Juega una partida después de medianoche.',
    ),
    Achievement(
      id: 'madrugador',
      title: 'Madrugador',
      description: 'Juega una partida antes de las 8 AM.',
    ),
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
