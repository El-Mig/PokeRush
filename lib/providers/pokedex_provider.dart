import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PokedexEntry {
  final String name;
  final bool hasShiny;

  PokedexEntry({required this.name, this.hasShiny = false});

  Map<String, dynamic> toJson() => {'name': name, 'hasShiny': hasShiny};
  factory PokedexEntry.fromJson(Map<String, dynamic> json) =>
      PokedexEntry(name: json['name'], hasShiny: json['hasShiny'] ?? false);
}

class PokedexNotifier extends StateNotifier<Map<int, PokedexEntry>> {
  PokedexNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('pokedex_data');
    if (data != null) {
      final Map<String, dynamic> decoded = json.decode(data);
      state = decoded.map((key, value) =>
          MapEntry(int.parse(key), PokedexEntry.fromJson(value)));
    }
  }

  Future<void> addPokemon(int id, String name, bool isShiny) async {
    final current = state[id];
    final entry = PokedexEntry(
      name: name,
      hasShiny: isShiny || (current?.hasShiny ?? false),
    );

    state = {...state, id: entry};

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'pokedex_data',
        json.encode(state
            .map((key, value) => MapEntry(key.toString(), value.toJson()))));
  }
}

final pokedexProvider =
    StateNotifierProvider<PokedexNotifier, Map<int, PokedexEntry>>((ref) {
  return PokedexNotifier();
});
