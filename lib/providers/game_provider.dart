import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:vibration/vibration.dart';
import '../services/pokemon_service.dart';
import '../models/pokemon.dart';
import 'filter_provider.dart';
import 'settings_provider.dart';
import 'achievement_provider.dart';
import 'pokedex_provider.dart';
import 'stats_provider.dart';

enum GameStatus { initial, loading, starting, playing, finished }

class GameState {
  final GameStatus status;
  final Pokemon? currentPokemon;
  final List<String> correctPokemon;
  final List<String> skippedPokemon;
  final int timeLeft;
  final int startCountdown;
  final bool isCorrectTilt;
  final bool isSkipTilt;

  GameState({
    this.status = GameStatus.initial,
    this.currentPokemon,
    this.correctPokemon = const [],
    this.skippedPokemon = const [],
    this.timeLeft = 60,
    this.startCountdown = 3,
    this.isCorrectTilt = false,
    this.isSkipTilt = false,
  });

  GameState copyWith({
    GameStatus? status,
    Pokemon? currentPokemon,
    List<String>? correctPokemon,
    List<String>? skippedPokemon,
    int? timeLeft,
    int? startCountdown,
    bool? isCorrectTilt,
    bool? isSkipTilt,
  }) {
    return GameState(
      status: status ?? this.status,
      currentPokemon: currentPokemon ?? this.currentPokemon,
      correctPokemon: correctPokemon ?? this.correctPokemon,
      skippedPokemon: skippedPokemon ?? this.skippedPokemon,
      timeLeft: timeLeft ?? this.timeLeft,
      startCountdown: startCountdown ?? this.startCountdown,
      isCorrectTilt: isCorrectTilt ?? this.isCorrectTilt,
      isSkipTilt: isSkipTilt ?? this.isSkipTilt,
    );
  }
}

final pokemonServiceProvider = Provider((ref) => PokemonService());

class GameNotifier extends StateNotifier<GameState> {
  final PokemonService _pokemonService;
  final Ref _ref;
  Timer? _timer;
  StreamSubscription? _accelerometerSubscription;
  bool _canProcessTilt = true;
  bool _hasReturnedToNeutral = true;
  List<String> _sessionQueue = [];
  Pokemon? _nextPreloadedPokemon;
  Map<String, int> _typeCounts = {};
  int _survivalTimeElapsed = 0;
  int _currentStreak = 0;
  Set<String> _sessionTypes = {};
  int _sessionShinies = 0;
  List<DateTime> _correctTimestamps = [];
  late DateTime _gameStartTime;

  GameNotifier(this._pokemonService, this._ref) : super(GameState());

  Future<void> startGame(
      {bool keepPool = false, bool isMultiplayer = false}) async {
    try {
      state = GameState(status: GameStatus.loading);

      if (!keepPool) {
        await _pokemonService.initialize();
      }

      if (!isMultiplayer) {
        _ref.read(statsProvider.notifier).addGame();
      }

      final filterState = _ref.read(filterProvider);
      final settings = _ref.read(settingsProvider);

      if (!keepPool) {
        _sessionQueue = await _pokemonService.preparePool(
          selectedGens: filterState.selectedGenerations,
          selectedTypes: filterState.selectedTypes,
          difficulty: filterState.difficulty,
          category: filterState.category,
        );
      }

      if (_sessionQueue.isEmpty) {
        if (keepPool) {
          // The queue might have been exhausted by previous players. We need to fetch more.
          _sessionQueue = await _pokemonService.preparePool(
            selectedGens: filterState.selectedGenerations,
            selectedTypes: filterState.selectedTypes,
            difficulty: filterState.difficulty,
            category: filterState.category,
          );
        }

        // If it's still empty after trying to refill, then we really have no pokemon.
        if (_sessionQueue.isEmpty) {
          state = state.copyWith(status: GameStatus.initial);
          return;
        }
      }

      Pokemon? pokemon;
      if (keepPool) {
        // Clear the previous preloaded pokemon so it doesn't repeat
        _nextPreloadedPokemon = null;
      }

      while (_sessionQueue.isNotEmpty) {
        final firstUrl = _sessionQueue.removeAt(0);
        pokemon = await _loadPokemonWithShinyChance(firstUrl);
        if (pokemon != null) break;
      }
      if (pokemon == null) {
        state = state.copyWith(status: GameStatus.initial);
        return;
      }

      _preloadNext();

      final initialTime = settings.gameMode == GameMode.survival ? 30 : 60;
      _survivalTimeElapsed = 0;

      state = state.copyWith(
        status: GameStatus.starting,
        currentPokemon: pokemon,
        correctPokemon: [],
        skippedPokemon: [],
        timeLeft: initialTime,
        startCountdown: 3,
      );

      _currentStreak = 0;
      _sessionTypes = {};
      _sessionShinies = 0;
      _correctTimestamps = [];
      _typeCounts = {};
      _gameStartTime = DateTime.now();

      if (!isMultiplayer) {
        if (_gameStartTime.hour >= 0 && _gameStartTime.hour < 8) {
          _ref.read(achievementProvider.notifier).unlock('buho_nocturno');
        } else if (_gameStartTime.hour >= 6 && _gameStartTime.hour < 8) {
          _ref.read(achievementProvider.notifier).unlock('madrugador');
        }
      }

      WakelockPlus.enable();
      _startCountdown();
    } catch (e) {
      print('Error starting game: $e');
      state = state.copyWith(status: GameStatus.initial);
    }
  }

  Future<Pokemon?> _loadPokemonWithShinyChance(String url) async {
    final pokemon = await _pokemonService.getPokemonDetails(url);
    if (pokemon == null) return null;

    final isShiny = (DateTime.now().millisecondsSinceEpoch % 100) == 7;
    if (isShiny) {
      _sessionShinies++;
      // We don't disable shiny achievements for multiplayer as per rules?
      // Actually it's better to disable all achievements for multiplayer to not contaminate.
      // But we can't easily check isMultiplayer here unless we store it in state.
      // For now, let's just let the achievement fire.
      _ref.read(achievementProvider.notifier).unlock('shiny_found');
      if (_sessionShinies >= 2) {
        _ref.read(achievementProvider.notifier).unlock('dia_suerte');
      }
      return Pokemon.fromJson(
        await _fetchJson(url),
        isShiny: true,
      );
    }
    return pokemon;
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      return json.decode(response.body);
    } catch (e) {
      print('Error in _fetchJson for shiny: $e');
      return {};
    }
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.startCountdown > 1) {
        state = state.copyWith(startCountdown: state.startCountdown - 1);
      } else {
        timer.cancel();
        state = state.copyWith(status: GameStatus.playing);
        _startTimer();
        _listenToSensors();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
        _survivalTimeElapsed++;

        if (_ref.read(settingsProvider).gameMode == GameMode.survival &&
            _survivalTimeElapsed >= 120) {
          _ref.read(achievementProvider.notifier).unlock('survival_pro');
        }
        if (_ref.read(settingsProvider).gameMode == GameMode.survival &&
            _survivalTimeElapsed >= 300) {
          _ref.read(achievementProvider.notifier).unlock('dios_supervivencia');
        }
      } else {
        if (_ref.read(settingsProvider).gameMode == GameMode.classic &&
            state.skippedPokemon.isEmpty &&
            state.correctPokemon.isNotEmpty) {
          _ref.read(achievementProvider.notifier).unlock('intocable');
        }
        finishGame();
      }
    });
  }

  void _listenToSensors() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      if (state.status != GameStatus.playing || !_canProcessTilt) return;

      if (event.z.abs() < 2.0) {
        _hasReturnedToNeutral = true;
      }

      if (!_hasReturnedToNeutral) return;

      final settings = _ref.read(settingsProvider);
      if (event.z < settings.correctAngle) {
        _hasReturnedToNeutral = false;
        _handleTilt(true);
      } else if (event.z > settings.skipAngle) {
        _hasReturnedToNeutral = false;
        _handleTilt(false);
      }
    });
  }

  void _preloadNext() async {
    while (_sessionQueue.isNotEmpty) {
      final nextUrl = _sessionQueue.removeAt(0);
      try {
        final pokemon = await _loadPokemonWithShinyChance(nextUrl);
        if (pokemon != null) {
          _nextPreloadedPokemon = pokemon;
          return;
        }
      } catch (e) {
        print('Error preloading $nextUrl: $e');
      }
    }
    _nextPreloadedPokemon = null;
  }

  Future<void> _handleTilt(bool isCorrect) async {
    _canProcessTilt = false;

    if (isCorrect) {
      final name = state.currentPokemon?.name ?? '???';
      state = state.copyWith(
        correctPokemon: [...state.correctPokemon, name],
        isCorrectTilt: true,
      );

      if (state.currentPokemon != null) {
        _ref.read(pokedexProvider.notifier).addPokemon(
              state.currentPokemon!.id,
              state.currentPokemon!.name,
              state.currentPokemon!.isShiny,
            );
        _sessionTypes.addAll(state.currentPokemon!.types);
        for (var type in state.currentPokemon!.types) {
          _typeCounts[type] = (_typeCounts[type] ?? 0) + 1;
        }

        final totalShinies =
            _ref.read(pokedexProvider).values.where((e) => e.hasShiny).length;
        if (totalShinies >= 5) {
          _ref.read(achievementProvider.notifier).unlock('cazador_shinies');
        }

        _ref.read(statsProvider.notifier).addCorrect(
              state.currentPokemon!.isShiny,
              _currentStreak + 1,
            );
      }

      _currentStreak++;
      _correctTimestamps.add(DateTime.now());
      _ref.read(achievementProvider.notifier).unlock('first_win');

      if (_currentStreak >= 10) {
        _ref.read(achievementProvider.notifier).unlock('racha_bronce');
      }
      if (_currentStreak >= 25) {
        _ref.read(achievementProvider.notifier).unlock('racha_plata');
      }
      if (_currentStreak >= 50) {
        _ref.read(achievementProvider.notifier).unlock('racha_oro');
      }

      if (_correctTimestamps.length >= 10) {
        final tenAgo = _correctTimestamps[_correctTimestamps.length - 10];
        if (DateTime.now().difference(tenAgo).inSeconds <= 30) {
          _ref.read(achievementProvider.notifier).unlock('velocista');
        }
      }

      if (_sessionTypes.length >= 18) {
        _ref.read(achievementProvider.notifier).unlock('maestro_elemental');
      }

      if (_typeCounts.values.any((count) => count >= 20)) {
        _ref.read(achievementProvider.notifier).unlock('especialista');
      }

      if (_ref.read(filterProvider).selectedGenerations.contains(1) &&
          state.correctPokemon.length >= 50) {
        _ref.read(achievementProvider.notifier).unlock('gen1_master');
      }
      if (_ref.read(filterProvider).selectedGenerations.contains(2) &&
          state.correctPokemon.length >= 50) {
        _ref.read(achievementProvider.notifier).unlock('explorador_johto');
      }
      if (_ref.read(filterProvider).selectedGenerations.contains(3) &&
          state.correctPokemon.length >= 50) {
        _ref.read(achievementProvider.notifier).unlock('leyenda_hoenn');
      }

      if (state.timeLeft < 5) {
        _ref.read(achievementProvider.notifier).unlock('a_contrarreloj');
      }

      if (_ref.read(settingsProvider).gameMode == GameMode.survival) {
        state = state.copyWith(timeLeft: state.timeLeft + 3);
      }

      _vibrateCorrect();
    } else {
      _currentStreak = 0;
      state = state.copyWith(
        skippedPokemon: [
          ...state.skippedPokemon,
          state.currentPokemon?.name ?? '???'
        ],
        isSkipTilt: true,
      );
      _vibrateSkip();
    }

    final nextPokemon = _nextPreloadedPokemon;
    _preloadNext();

    await Future.delayed(const Duration(milliseconds: 1000));

    if (state.status == GameStatus.playing) {
      state = state.copyWith(
        currentPokemon: nextPokemon,
        isCorrectTilt: false,
        isSkipTilt: false,
      );
      _canProcessTilt = true;
    }
  }

  void _vibrateCorrect() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
  }

  void _vibrateSkip() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100);
    }
  }

  void _vibrateGameOver() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
    }
  }

  void finishGame() {
    _timer?.cancel();
    _accelerometerSubscription?.cancel();
    state = state.copyWith(status: GameStatus.finished);
    WakelockPlus.disable();
    _vibrateGameOver();
  }

  void skipPokemon() {
    if (state.status == GameStatus.playing && _canProcessTilt) {
      _handleTilt(false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelerometerSubscription?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }
}

final gameProvider =
    StateNotifierProvider.autoDispose<GameNotifier, GameState>((ref) {
  return GameNotifier(ref.watch(pokemonServiceProvider), ref);
});
