import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokerush/l10n/app_localizations.dart';
import '../providers/multiplayer_provider.dart';
import '../models/player_score.dart';
import '../widgets/holographic_card.dart';
import 'home_screen.dart';

class TournamentResultsScreen extends ConsumerWidget {
  const TournamentResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final multiplayerState = ref.watch(multiplayerProvider);

    // Sort players by score descending
    final sortedPlayers = List<PlayerScore>.from(multiplayerState.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tournamentResults,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevents back button during results
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey.shade900, Colors.black],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (sortedPlayers.isNotEmpty)
              _buildPodiumTop(sortedPlayers.first, l10n),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedPlayers.length,
                itemBuilder: (context, index) {
                  return _buildPlayerCard(sortedPlayers[index], index);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(multiplayerProvider.notifier).reset();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.backToHome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumTop(PlayerScore winner, AppLocalizations l10n) {
    return Column(
      children: [
        const Icon(Icons.emoji_events,
            size: 80, color: Color(0xFFF7D02C)), // Gold
        const SizedBox(height: 8),
        Text(
          l10n.winner.toUpperCase(),
          style: const TextStyle(
              color: Colors.white54, fontSize: 16, letterSpacing: 2),
        ),
        Text(
          winner.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${winner.score} pts',
          style: const TextStyle(
            color: Color(0xFFF7D02C),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(PlayerScore player, int index) {
    Color cardColor;
    Color textColor = Colors.white;
    String positionText = '#${index + 1}';

    switch (index) {
      case 0:
        cardColor = const Color(0xFFF7D02C); // Gold/Electric
        textColor = Colors.black;
        break;
      case 1:
        cardColor = const Color(0xFFB7B7CE); // Silver/Steel
        textColor = Colors.black;
        break;
      case 2:
        cardColor = const Color(0xFFE2BF65); // Bronze/Ground
        textColor = Colors.black;
        break;
      default:
        // For others, we can use a gray or random type color
        cardColor = const Color(0xFF424242);
        break;
    }

    Widget card = Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: index == 0 ? 8 : 1, // Higher elevation for the winner
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.black26,
          child: Text(
            positionText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          '${player.score} pts',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    if (index == 0) {
      // Apply holographic effect ONLY to the first place winner
      return HolographicCard(
        child: card,
      );
    }

    return card;
  }
}
