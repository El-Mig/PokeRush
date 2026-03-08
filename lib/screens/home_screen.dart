import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_screen.dart';
import 'filter_screen.dart';
import 'pokedex_screen.dart';
import '../providers/filter_provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import 'package:pokerush/l10n/app_localizations.dart';
import 'player_registration_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3B1010),
                Color(0xFF1A1A1A)
              ], // Muted Pokéball Theme
              stops: [0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Top Right Settings Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.settings,
                        color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FilterScreen()),
                      );
                    },
                  ),
                ),
                // Top Left Pokedex Button
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.menu_book,
                        color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PokedexScreen()),
                      );
                    },
                  ),
                ),
                // Main Content Centered
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'PokeRush',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black45)
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // GAME MODE SELECTOR
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.transparent,
                            ),
                            child: SegmentedButton<GameMode>(
                              segments: [
                                ButtonSegment<GameMode>(
                                  value: GameMode.classic,
                                  label: Text(l10n.classic,
                                      style: const TextStyle(fontSize: 12)),
                                  icon: const Icon(Icons.timer_outlined),
                                ),
                                ButtonSegment<GameMode>(
                                  value: GameMode.survival,
                                  label: Text(l10n.survival,
                                      style: const TextStyle(fontSize: 12)),
                                  icon: const Icon(Icons.bolt),
                                ),
                              ],
                              selected: {settings.gameMode},
                              onSelectionChanged: (Set<GameMode> newSelection) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .setGameMode(newSelection.first);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return const Color(0xFFD4A017);
                                    }
                                    return Colors.white10;
                                  },
                                ),
                                foregroundColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Colors.black;
                                    }
                                    return Colors.white70;
                                  },
                                ),
                                side: WidgetStateProperty.all(
                                    const BorderSide(color: Colors.white24)),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            final filterState = ref.read(filterProvider);
                            final pokemonService =
                                ref.read(pokemonServiceProvider);

                            // Quick check for empty pool before loading
                            final pool = await pokemonService.preparePool(
                              selectedGens: filterState.selectedGenerations,
                              selectedTypes: filterState.selectedTypes,
                            );

                            if (pool.isEmpty) {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF2C2C2C),
                                    title: Text(l10n.noPokemonTitle,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    content: Text(
                                      l10n.noPokemonContent,
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(l10n.accept,
                                            style: const TextStyle(
                                                color: Color(0xFFD4A017))),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return;
                            }

                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const GameScreen()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFD4A017), // Muted Golden Yellow
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 20,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                  color: Colors.black26, width: 2),
                            ),
                          ),
                          child: Text(l10n.play),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PlayerRegistrationScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF2C3E50), // Muted Midnight Blue
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                  color: Colors.black26, width: 2),
                            ),
                          ),
                          child: Text(l10n.localTournament),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          l10n.instructions,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
