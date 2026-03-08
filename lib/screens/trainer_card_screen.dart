import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/stats_provider.dart';
import '../providers/pokedex_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/settings_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pokerush/l10n/app_localizations.dart';

class TrainerCardScreen extends ConsumerWidget {
  const TrainerCardScreen({super.key});

  final List<IconData> _avatars = const [
    Icons.person,
    Icons.catching_pokemon,
    Icons.face,
    Icons.pets,
    Icons.bolt,
    Icons.local_fire_department,
    Icons.water_drop,
    Icons.grass,
    Icons.psychology,
    Icons.auto_awesome,
    Icons.shield,
    Icons.military_tech,
    Icons.star,
    Icons.celebration,
    Icons.sports_esports,
    Icons.workspace_premium,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final pokedex = ref.watch(pokedexProvider);
    final achievements = ref.watch(achievementProvider);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final caughtCount = pokedex.length;
    final shinyCount = pokedex.values.where((p) => p.hasShiny).length;
    final unlockedAchievements = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(l10n.trainerCard),
        backgroundColor: const Color(0xFF3B1010),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBC2C2C), Color(0xFF3B1010)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _showAvatarSelectionDialog(
                        context, settings, settingsNotifier, l10n),
                    child: CircleAvatar(
                      key: ValueKey(settings.avatarPath),
                      radius: 50,
                      backgroundColor: Colors.white24,
                      backgroundImage: settings.avatarPath != null
                          ? (kIsWeb ||
                                  settings.avatarPath!.startsWith('data:image')
                              ? MemoryImage(base64Decode(
                                  settings.avatarPath!.split(',').last))
                              : FileImage(File(settings.avatarPath!))
                                  as ImageProvider)
                          : null,
                      onBackgroundImageError: settings.avatarPath != null
                          ? (exception, stackTrace) {
                              debugPrint("Error loading image: $exception");
                            }
                          : null,
                      child: settings.avatarPath == null
                          ? Icon(_avatars[settings.avatarIndex],
                              size: 60, color: Colors.white)
                          : null,
                    ).animate().scale(
                        delay: 200.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutBack),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => _showNameEditDialog(
                        context, settings.trainerName, settingsNotifier, l10n),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          settings.trainerName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit, color: Colors.white54, size: 16),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
                  const SizedBox(height: 5),
                  Text(
                    l10n.trainer,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 30),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _StatItem(
                  icon: Icons.catching_pokemon,
                  label: "POKÉDEX",
                  value: "$caughtCount/1025",
                  color: Colors.redAccent,
                ).animate().fadeIn(delay: 100.ms).scale(delay: 100.ms),
                _StatItem(
                  icon: Icons.star,
                  label: l10n.shinies,
                  value: "$shinyCount",
                  color: Colors.yellowAccent,
                ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms),
                _StatItem(
                  icon: Icons.emoji_events,
                  label: l10n.achievements.toUpperCase(),
                  value: "$unlockedAchievements/${achievements.length}",
                  color: Colors.orangeAccent,
                ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),
                _StatItem(
                  icon: Icons.bolt,
                  label: l10n.bestStreak,
                  value: "${stats.bestStreak}",
                  color: Colors.blueAccent,
                ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms),
              ],
            ),
            const SizedBox(height: 25),

            // More Stats
            _StatRow(
              icon: Icons.play_arrow,
              label: l10n.gamesPlayed,
              value: "${stats.totalGames}",
            ),
            _StatRow(
              icon: Icons.check_circle,
              label: l10n.totalCorrectStats,
              value: "${stats.totalCorrect}",
            ),

            const SizedBox(height: 40),

            // Decorative note
            Text(
              l10n.profileKeepGoing,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNameEditDialog(BuildContext context, String currentName,
      SettingsNotifier notifier, AppLocalizations l10n) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title:
            Text(l10n.changeName, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.enterName,
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                notifier.setTrainerName(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
      BuildContext context, SettingsNotifier notifier) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: kIsWeb, // Important for Web
      );

      if (result != null) {
        if (kIsWeb) {
          final bytes = result.files.single.bytes;
          if (bytes != null) {
            final base64String = "data:image/png;base64,${base64Encode(bytes)}";
            notifier.setAvatarPath(base64String);
          }
        } else if (result.files.single.path != null) {
          final pickedFile = File(result.files.single.path!);
          final appDir = await getApplicationDocumentsDirectory();
          final fileName =
              "avatar_${DateTime.now().millisecondsSinceEpoch}${p.extension(result.files.single.path!)}";
          final localPath = p.join(appDir.path, fileName);
          await pickedFile.copy(localPath);
          notifier.setAvatarPath(localPath);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Foto de perfil actualizada!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error seleccionando imagen: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showAvatarSelectionDialog(BuildContext context, SettingsState settings,
      SettingsNotifier notifier, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(l10n.selectAvatar,
            style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: Text(l10n.chooseFromGallery,
                    style: const TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(context, notifier);
                },
              ),
              if (settings.avatarPath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: Text(l10n.removePhoto,
                      style: const TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    notifier.setAvatarPath(null);
                    Navigator.pop(context);
                  },
                ),
              const Divider(color: Colors.white10),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final isSelected = settings.avatarPath == null &&
                        index == settings.avatarIndex;
                    return InkWell(
                      onTap: () {
                        notifier.setAvatarIndex(index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFBC2C2C)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white54
                                : Colors.transparent,
                          ),
                        ),
                        child: Icon(
                          _avatars[index],
                          color: isSelected ? Colors.white : Colors.white54,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white54, size: 20),
              const SizedBox(width: 15),
              Text(label, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
