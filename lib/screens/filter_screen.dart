import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../providers/settings_provider.dart';
import 'package:pokerush/l10n/app_localizations.dart';
import '../providers/achievement_provider.dart';
import '../providers/cache_provider.dart';
import 'trainer_card_screen.dart';

class FilterScreen extends ConsumerWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final achievements = ref.watch(achievementProvider);

    final allTypes = [
      'NORMAL',
      'FIRE',
      'WATER',
      'ELECTRIC',
      'GRASS',
      'ICE',
      'FIGHTING',
      'POISON',
      'GROUND',
      'FLYING',
      'PSYCHIC',
      'BUG',
      'ROCK',
      'GHOST',
      'DRAGON',
      'STEEL',
      'DARK',
      'FAIRY'
    ];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          title: Text(l10n.settings),
          backgroundColor: const Color(0xFF3B1010),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => notifier.resetFilters(),
              icon: const Icon(Icons.refresh),
              tooltip: l10n.resetFilters,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TrainerCardScreen()),
                );
              },
              icon: const Icon(Icons.badge_outlined),
              tooltip: "Tarjeta de Entrenador",
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: const Color(0xFFD4A017),
            labelColor: const Color(0xFFD4A017),
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: l10n.tabFilters),
              Tab(text: l10n.tabGame),
              Tab(text: l10n.tabSettings),
              Tab(text: l10n.tabAchievements),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: FILTERS
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(l10n.generations),
                  const SizedBox(height: 15),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final gen = index + 1;
                      final isSelected =
                          filterState.selectedGenerations.contains(gen);
                      return _FilterChip(
                        label: 'GEN $gen',
                        isSelected: isSelected,
                        onTap: () => notifier.toggleGeneration(gen),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  _sectionHeader(l10n.types),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: allTypes.map((type) {
                      final isSelected =
                          filterState.selectedTypes.contains(type);
                      return _FilterChip(
                        label: type,
                        isSelected: isSelected,
                        onTap: () => notifier.toggleType(type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      l10n.filterNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _sectionHeader(l10n.thematicCategories),
                  const SizedBox(height: 15),
                  Center(
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment<String>(
                          value: 'All',
                          label: Text(l10n.all),
                        ),
                        ButtonSegment<String>(
                          value: 'Starters',
                          label: Text(l10n.starters),
                        ),
                        ButtonSegment<String>(
                          value: 'Legendaries',
                          label: Text(l10n.legendaries),
                        ),
                      ],
                      selected: {filterState.category},
                      onSelectionChanged: (Set<String> newSelection) {
                        notifier.setCategory(newSelection.first);
                      },
                      style: _segmentedButtonStyle(),
                    ),
                  ),
                ],
              ),
            ),

            // TAB 2: GAMEPLAY
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(l10n.difficulty),
                  const SizedBox(height: 15),
                  Center(
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment<String>(
                          value: 'Normal',
                          label: Text(l10n.difficultyNormal),
                        ),
                        ButtonSegment<String>(
                          value: 'Expert',
                          label: Text(l10n.difficultyExpert),
                        ),
                      ],
                      selected: {filterState.difficulty},
                      onSelectionChanged: (Set<String> newSelection) {
                        notifier.setDifficulty(newSelection.first);
                      },
                      style: _segmentedButtonStyle(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _sectionHeader(l10n.sensorCalibration),
                  const SizedBox(height: 15),
                  _CalibrationSlider(
                    label: l10n.correctSensitivity,
                    value: settings.correctAngle,
                    min: -15.0,
                    max: -2.0,
                    onChanged: (val) =>
                        settingsNotifier.setAngles(val, settings.skipAngle),
                  ),
                  const SizedBox(height: 10),
                  _CalibrationSlider(
                    label: l10n.skipSensitivity,
                    value: settings.skipAngle,
                    min: 2.0,
                    max: 15.0,
                    onChanged: (val) =>
                        settingsNotifier.setAngles(settings.correctAngle, val),
                  ),
                ],
              ),
            ),

            // TAB 3: APP SETTINGS
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(l10n.language),
                  const SizedBox(height: 15),
                  Center(
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment<String>(
                          value: 'es',
                          label: Text(l10n.spanish),
                        ),
                        ButtonSegment<String>(
                          value: 'en',
                          label: Text(l10n.english),
                        ),
                      ],
                      selected: {settings.locale},
                      onSelectionChanged: (Set<String> newSelection) {
                        settingsNotifier.setLocale(newSelection.first);
                      },
                      style: _segmentedButtonStyle(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _sectionHeader(l10n.visualSettings),
                  const SizedBox(height: 5),
                  SwitchListTile(
                    title: Text(l10n.dynamicBackgrounds,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(l10n.dynamicBackgroundsDesc,
                        style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    value: settings.dynamicBackgrounds,
                    onChanged: (val) =>
                        settingsNotifier.toggleDynamicBackgrounds(val),
                    activeColor: const Color(0xFFD4A017),
                  ),
                  const SizedBox(height: 40),
                  _sectionHeader(l10n.offlineStorage),
                  const SizedBox(height: 15),
                  Consumer(
                    builder: (context, ref, child) {
                      final cacheState = ref.watch(cacheProvider);
                      final cacheNotifier = ref.read(cacheProvider.notifier);

                      if (cacheState.isDownloading) {
                        final progress = cacheState.totalItemCount > 0
                            ? cacheState.currentProgress /
                                cacheState.totalItemCount
                            : 0.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.downloadingPokedex(
                                  cacheState.currentProgress,
                                  cacheState.totalItemCount),
                              style: const TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFD4A017)),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ],
                        );
                      }

                      if (cacheState.isComplete) {
                        return Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                l10n.downloadComplete,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (cacheState.errorMessage != null) {
                        return Center(
                          child: Text(
                            '${l10n.downloadError}: ${cacheState.errorMessage}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              cacheNotifier.downloadEntirePokedex(),
                          icon: const Icon(Icons.download, color: Colors.black),
                          label: Text(
                            l10n.downloadPokedex,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A017), // Gold
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // TAB 4: ACHIEVEMENTS
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(l10n.achievements),
                  const SizedBox(height: 15),
                  ...achievements
                      .map((ach) => _AchievementTile(achievement: ach)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  ButtonStyle _segmentedButtonStyle() {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFD4A017);
          }
          return Colors.white10;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.black;
          }
          return Colors.white70;
        },
      ),
    );
  }
}

class _CalibrationSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;

  const _CalibrationSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 26,
          label: value.toStringAsFixed(1),
          activeColor: const Color(0xFFD4A017),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String getTitle() {
      switch (achievement.id) {
        case 'first_win':
          return l10n.ach_first_win_title;
        case 'gen1_master':
          return l10n.ach_gen1_master_title;
        case 'shiny_found':
          return l10n.ach_shiny_found_title;
        case 'survival_pro':
          return l10n.ach_survival_pro_title;
        case 'velocista':
          return l10n.ach_velocista_title;
        case 'racha_bronce':
          return l10n.ach_racha_bronce_title;
        case 'racha_plata':
          return l10n.ach_racha_plata_title;
        case 'racha_oro':
          return l10n.ach_racha_oro_title;
        case 'intocable':
          return l10n.ach_intocable_title;
        case 'maestro_elemental':
          return l10n.ach_maestro_elemental_title;
        case 'explorador_johto':
          return l10n.ach_explorador_johto_title;
        case 'leyenda_hoenn':
          return l10n.ach_leyenda_hoenn_title;
        case 'especialista':
          return l10n.ach_especialista_title;
        case 'dios_supervivencia':
          return l10n.ach_dios_supervivencia_title;
        case 'a_contrarreloj':
          return l10n.ach_a_contrarreloj_title;
        case 'cazador_shinies':
          return l10n.ach_cazador_shinies_title;
        case 'dia_suerte':
          return l10n.ach_dia_suerte_title;
        case 'buho_nocturno':
          return l10n.ach_buho_nocturno_title;
        case 'madrugador':
          return l10n.ach_madrugador_title;
        default:
          return achievement.id;
      }
    }

    String getDescription() {
      switch (achievement.id) {
        case 'first_win':
          return l10n.ach_first_win_desc;
        case 'gen1_master':
          return l10n.ach_gen1_master_desc;
        case 'shiny_found':
          return l10n.ach_shiny_found_desc;
        case 'survival_pro':
          return l10n.ach_survival_pro_desc;
        case 'velocista':
          return l10n.ach_velocista_desc;
        case 'racha_bronce':
          return l10n.ach_racha_bronce_desc;
        case 'racha_plata':
          return l10n.ach_racha_plata_desc;
        case 'racha_oro':
          return l10n.ach_racha_oro_desc;
        case 'intocable':
          return l10n.ach_intocable_desc;
        case 'maestro_elemental':
          return l10n.ach_maestro_elemental_desc;
        case 'explorador_johto':
          return l10n.ach_explorador_johto_desc;
        case 'leyenda_hoenn':
          return l10n.ach_leyenda_hoenn_desc;
        case 'especialista':
          return l10n.ach_especialista_desc;
        case 'dios_supervivencia':
          return l10n.ach_dios_supervivencia_desc;
        case 'a_contrarreloj':
          return l10n.ach_a_contrarreloj_desc;
        case 'cazador_shinies':
          return l10n.ach_cazador_shinies_desc;
        case 'dia_suerte':
          return l10n.ach_dia_suerte_desc;
        case 'buho_nocturno':
          return l10n.ach_buho_nocturno_desc;
        case 'madrugador':
          return l10n.ach_madrugador_desc;
        default:
          return '';
      }
    }

    return Opacity(
      opacity: achievement.isUnlocked ? 1.0 : 0.4,
      child: Card(
        color: Colors.white10,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Icon(
            achievement.isUnlocked ? Icons.stars : Icons.stars_outlined,
            color: achievement.isUnlocked
                ? const Color(0xFFD4A017)
                : Colors.white30,
            size: 40,
          ),
          title: Text(
            getTitle(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            getDescription(),
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          trailing: achievement.isUnlocked
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.lock, color: Colors.white24),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4A017) : Colors.white10,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.white30 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
