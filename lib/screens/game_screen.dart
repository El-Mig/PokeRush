import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/filter_provider.dart';
import 'package:pokerush/l10n/app_localizations.dart';
import 'results_screen.dart';
import 'turn_transition_screen.dart';
import 'tournament_results_screen.dart';
import '../providers/multiplayer_provider.dart';
import '../widgets/dynamic_particles_background.dart';

class GameScreen extends ConsumerStatefulWidget {
  final bool isMultiplayer;
  const GameScreen({super.key, this.isMultiplayer = false});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Lock to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide status bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Start the game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isFirstTurn = ref.read(multiplayerProvider).currentPlayerIndex == 0;
      ref.read(gameProvider.notifier).startGame(
            keepPool: widget.isMultiplayer && !isFirstTurn,
            isMultiplayer: widget.isMultiplayer,
          );
    });
  }

  @override
  void dispose() {
    // Restore orientation and system UI
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final filterState = ref.watch(filterProvider);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    // Navigate to results when finished
    if (gameState.status == GameStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.isMultiplayer) {
          final multiplayerNotifier = ref.read(multiplayerProvider.notifier);
          final multiplayerState = ref.read(multiplayerProvider);

          multiplayerNotifier.recordTurnResults(
            score: gameState.correctPokemon.length,
            correctPokemon: gameState.correctPokemon,
            skippedPokemon: gameState.skippedPokemon,
          );

          if (multiplayerState.isLastPlayer) {
            multiplayerNotifier.finishTournament();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const TournamentResultsScreen()),
            );
          } else {
            final nextIndex = multiplayerState.currentPlayerIndex + 1;
            final nextPlayerName = multiplayerState.players[nextIndex].name;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TurnTransitionScreen(nextPlayerName: nextPlayerName)),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ResultsScreen()),
          );
        }
      });
    }

    if (gameState.status == GameStatus.loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                l10n.ready, // repurposed for loading
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    if (gameState.status == GameStatus.starting) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${gameState.startCountdown}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.ready,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (gameState.status == GameStatus.initial) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 80),
              const SizedBox(height: 20),
              const Text(
                "¡ERROR DE CONEXIÓN!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "No se pudo cargar la Pokédex.\nRevisa tu internet.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  final isFirstTurn = widget.isMultiplayer &&
                      ref.read(multiplayerProvider).currentPlayerIndex == 0;
                  ref.read(gameProvider.notifier).startGame(
                        keepPool: widget.isMultiplayer && !isFirstTurn,
                        isMultiplayer: widget.isMultiplayer,
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBC2C2C),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("REINTENTAR",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.backToHome,
                    style: const TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      );
    }

    final currentPokemon = gameState.currentPokemon;

    Color backgroundColor = const Color(0xFF2C3E50); // Muted Midnight Blue
    String feedbackText = "";

    if (gameState.isCorrectTilt) {
      backgroundColor = const Color(0xFF1E8449); // Muted Dark Emerald
      feedbackText = l10n.correct;
    } else if (gameState.isSkipTilt) {
      backgroundColor = const Color(0xFF922B21); // Muted Dark Iron Red
      feedbackText = l10n.skipped;
    } else if (settings.dynamicBackgrounds && currentPokemon != null) {
      backgroundColor =
          _getTypeColor(currentPokemon.types.first).withOpacity(0.8);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  backgroundColor,
                  backgroundColor.withOpacity(0.5),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Particles
          if (settings.dynamicBackgrounds &&
              currentPokemon != null &&
              currentPokemon.isShiny)
            DynamicParticlesBackground(baseColor: backgroundColor),

          SafeArea(
            child: Stack(
              children: [
                // Exit Button
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Timer
                Positioned(
                  top: 20,
                  right: 20,
                  child: Text(
                    '${gameState.timeLeft}',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Current Pokemon / Feedback
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenHeight = constraints.maxHeight;
                      final spriteSize =
                          (screenHeight * 0.45).clamp(100.0, 250.0);
                      final nameFontSize =
                          (screenHeight * 0.15).clamp(24.0, 64.0);
                      final typeFontSize =
                          (screenHeight * 0.05).clamp(12.0, 20.0);

                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (feedbackText.isNotEmpty)
                              Text(
                                feedbackText,
                                style: TextStyle(
                                  fontSize:
                                      (screenHeight * 0.2).clamp(40.0, 100.0),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else if (currentPokemon != null) ...[
                              // Generation Label (Hidden in Expert Mode)
                              if (filterState.difficulty != 'Expert') ...[
                                Text(
                                  currentPokemon.generationText,
                                  style: TextStyle(
                                    fontSize:
                                        (screenHeight * 0.04).clamp(14.0, 24.0),
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                              ],
                              // Sprite Stack (for Shiny Sparkles)
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (currentPokemon.isShiny)
                                    const _ShinySparkles(),
                                  CachedNetworkImage(
                                    imageUrl: currentPokemon.currentSpriteUrl,
                                    height: spriteSize,
                                    width: spriteSize,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => SizedBox(
                                      height: spriteSize,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error,
                                            color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              // Name
                              Text(
                                currentPokemon.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: nameFontSize,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              // Types (Hidden in Expert Mode)
                              if (filterState.difficulty != 'Expert')
                                Wrap(
                                  // Use Wrap instead of Row to handle small widths
                                  alignment: WrapAlignment.center,
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: currentPokemon.types.map((type) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(type),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: typeFontSize,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ] else
                              const Text(
                                "...",
                                style: TextStyle(
                                    fontSize: 40, color: Colors.white),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Score Indicator
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    '${l10n.score}: ${gameState.correctPokemon.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Skip Button
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: InkWell(
                    onTap: () => ref.read(gameProvider.notifier).skipPokemon(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SKIP ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Icon(Icons.skip_next, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'NORMAL':
        return const Color(0xFFA8A77A);
      case 'FIRE':
        return const Color(0xFFEE8130);
      case 'WATER':
        return const Color(0xFF6390F0);
      case 'ELECTRIC':
        return const Color(0xFFF7D02C);
      case 'GRASS':
        return const Color(0xFF7AC74C);
      case 'ICE':
        return const Color(0xFF96D9D6);
      case 'FIGHTING':
        return const Color(0xFFC22E28);
      case 'POISON':
        return const Color(0xFFA33EA1);
      case 'GROUND':
        return const Color(0xFFE2BF65);
      case 'FLYING':
        return const Color(0xFFA98FF3);
      case 'PSYCHIC':
        return const Color(0xFFF95587);
      case 'BUG':
        return const Color(0xFFA6B91A);
      case 'ROCK':
        return const Color(0xFFB6A136);
      case 'GHOST':
        return const Color(0xFF735797);
      case 'DRAGON':
        return const Color(0xFF6F35FC);
      case 'STEEL':
        return const Color(0xFFB7B7CE);
      case 'DARK':
        return const Color(0xFF705746);
      case 'FAIRY':
        return const Color(0xFFD685AD);
      default:
        return Colors.grey;
    }
  }
}

class _ShinySparkles extends StatefulWidget {
  const _ShinySparkles();

  @override
  State<_ShinySparkles> createState() => _ShinySparklesState();
}

class _ShinySparklesState extends State<_ShinySparkles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: (1.0 - _controller.value).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 1.0 + (_controller.value * 0.5),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.yellowAccent,
              size: 200,
            ),
          ),
        );
      },
    );
  }
}
