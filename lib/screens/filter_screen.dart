import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../providers/settings_provider.dart';
import 'package:pokerush/l10n/app_localizations.dart';
import '../providers/achievement_provider.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(l10n.filters),
        backgroundColor: const Color(0xFF3B1010),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => notifier.resetFilters(),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.resetFilters,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.generations,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            Text(
              l10n.types,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: allTypes.map((type) {
                final isSelected = filterState.selectedTypes.contains(type);
                return _FilterChip(
                  label: type,
                  isSelected: isSelected,
                  onTap: () => notifier.toggleType(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
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
            const SizedBox(height: 60), // Increased to avoid Android buttons

            const SizedBox(height: 40),

            // LANGUAGE
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
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFFD4A017);
                      }
                      return Colors.white10;
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // VISUAL SETTINGS
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

            // CALIBRATION
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

            const SizedBox(height: 40),

            // ACHIEVEMENTS
            _sectionHeader(l10n.achievements),
            const SizedBox(height: 15),
            ...achievements.map((ach) => _AchievementTile(achievement: ach)),

            const SizedBox(height: 40),
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
            achievement.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            achievement.description,
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
