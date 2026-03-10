import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'package:pokerush/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/holographic_card.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gameOver),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFBC2C2C), // Muted Crimson
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: HolographicCard(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBC2C2C), Color(0xFF6A1B1B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  '${l10n.score}: ${gameState.correctPokemon.length}',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          ),
          Expanded(
            child: ListView(
              children: [
                if (gameState.correctPokemon.isNotEmpty) ...[
                  ListTile(
                    title: Text(
                      l10n.correct.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  ...gameState.correctPokemon.map(
                    (p) => ListTile(
                      leading: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: Text(p),
                    ),
                  ),
                ],
                if (gameState.skippedPokemon.isNotEmpty) ...[
                  const Divider(),
                  ListTile(
                    title: Text(
                      l10n.skipped.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  ...gameState.skippedPokemon.map(
                    (p) => ListTile(
                      leading: const Icon(Icons.skip_next, color: Colors.red),
                      title: Text(p),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBC2C2C), // Muted Crimson
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                l10n.backToHome.toUpperCase(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5),
          ),
        ],
      ),
    );
  }
}
