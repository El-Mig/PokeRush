import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokerush/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/multiplayer_provider.dart';
import 'game_screen.dart';

class PlayerRegistrationScreen extends ConsumerStatefulWidget {
  const PlayerRegistrationScreen({super.key});

  @override
  ConsumerState<PlayerRegistrationScreen> createState() =>
      _PlayerRegistrationScreenState();
}

class _PlayerRegistrationScreenState
    extends ConsumerState<PlayerRegistrationScreen> {
  List<TextEditingController> _controllers = [
    TextEditingController(text: 'Jugador 1'),
    TextEditingController(text: 'Jugador 2'),
  ];

  static const _prefsKey = 'tournament_players';

  @override
  void initState() {
    super.initState();
    _loadSavedPlayers();
  }

  Future<void> _loadSavedPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPlayersJson = prefs.getString(_prefsKey);

    if (savedPlayersJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(savedPlayersJson);
        final savedNames = decoded.cast<String>();

        if (savedNames.length >= 2) {
          setState(() {
            _controllers = savedNames
                .map((name) => TextEditingController(text: name))
                .toList();
          });
        }
      } catch (e) {
        print('Error parsing saved tournament players: $e');
      }
    }
  }

  void _addPlayer() {
    setState(() {
      _controllers.add(
          TextEditingController(text: 'Jugador ${_controllers.length + 1}'));
    });
  }

  void _removePlayer(int index) {
    if (_controllers.length > 2) {
      setState(() {
        _controllers.removeAt(index).dispose();
      });
    }
  }

  Future<void> _startTournament() async {
    final playerNames = _controllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (playerNames.length >= 2) {
      // Save names for future sessions
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(playerNames));

      ref.read(multiplayerProvider.notifier).startTournament(playerNames);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const GameScreen(isMultiplayer: true),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.localTournament,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                l10n.enterPlayerName,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _controllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controllers[index],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: '${l10n.playerName} ${index + 1}',
                                labelStyle:
                                    const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          if (_controllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.redAccent),
                              onPressed: () => _removePlayer(index),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addPlayer,
                icon: const Icon(Icons.add),
                label: Text(l10n.addPlayer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startTournament,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.startTournament,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
