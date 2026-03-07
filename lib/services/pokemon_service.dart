import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  // Cache for pokemon names and their detail URLs
  List<Map<String, String>> _allPokemonData = [];
  List<Map<String, String>> get allPokemonData => _allPokemonData;
  int _totalCount = 0;

  Future<void> initialize() async {
    if (_allPokemonData.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    // Check if we have cached basic data
    final cachedData = prefs.getString('pokemon_basic_data');
    if (cachedData != null) {
      final List decoded = json.decode(cachedData);
      _allPokemonData =
          decoded.map((e) => Map<String, String>.from(e)).toList();
      _totalCount = _allPokemonData.length;
      print('DEBUG: Loaded ${_allPokemonData.length} Pokemon from cache');
      return;
    }

    try {
      // First, get the total count
      final response = await http
          .get(Uri.parse('$_baseUrl/pokemon?limit=1'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _totalCount = data['count'];

        // Fetch ALL names and URLs for randomizing
        final allResponse = await http
            .get(Uri.parse('$_baseUrl/pokemon?limit=$_totalCount'))
            .timeout(const Duration(seconds: 15));
        if (allResponse.statusCode == 200) {
          final allData = json.decode(allResponse.body);
          final List results = allData['results'];
          _allPokemonData = results
              .map((e) => {
                    'name': (e['name'] as String).toUpperCase(),
                    'url': e['url'] as String,
                  })
              .toList();

          // Save to cache for offline mode
          await prefs.setString(
              'pokemon_basic_data', json.encode(_allPokemonData));
          print(
              'DEBUG: Cached ${_allPokemonData.length} Pokemon for offline use');
        }
      }
    } catch (e) {
      print('Error initializing PokemonService: $e');
    }
  }

  Future<Pokemon?> getPokemonDetails(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'pokemon_detail_$url';

    // Check cache first
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final data = json.decode(cached);
        return Pokemon.fromJson(data);
      } catch (_) {
        // Fallback to network if cache is corrupted
      }
    }

    try {
      final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 8)); // Timeout to prevent getting stuck
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Save to cache for offline use
        await prefs.setString(cacheKey, response.body);
        return Pokemon.fromJson(data);
      }
    } catch (e) {
      print('Error fetching pokemon details: $e');
    }
    return null;
  }

  // Pre-cache a batch of pokemon (e.g. Gen 1) to ensure offline variety
  Future<void> cacheBatchDetails({int start = 1, int end = 151}) async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();

    print('DEBUG: Starting proactive caching for IDs $start to $end...');
    int cachedCount = 0;

    for (int i = start; i <= end; i++) {
      final url = '$_baseUrl/pokemon/$i/';
      final cacheKey = 'pokemon_detail_$url';

      if (!prefs.containsKey(cacheKey)) {
        try {
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            await prefs.setString(cacheKey, response.body);
            cachedCount++;
            // Small delay to be polite to the API
            await Future.delayed(const Duration(milliseconds: 100));
          }
        } catch (e) {
          print('DEBUG: Failed to pre-cache ID $i: $e');
          // If we hit an error (likely no internet), stop the batch
          break;
        }
      }
    }
    print('DEBUG: Proactive caching finished. Added $cachedCount new Pokemon.');
  }

  bool isCached(String url, SharedPreferences prefs) {
    return prefs.containsKey('pokemon_detail_$url');
  }

  Future<List<String>> preparePool({
    required List<int> selectedGens,
    required List<String> selectedTypes,
  }) async {
    await initialize();

    // 1. Get IDs from selected generations
    Set<int> genIds = {};
    for (var gen in selectedGens) {
      genIds.addAll(_getIdsForGen(gen));
    }

    // 2. Filter by types if specified
    if (selectedTypes.isNotEmpty) {
      Set<int> typeIds = {};
      for (var type in selectedTypes) {
        final ids = await _fetchIdsByType(type.toLowerCase());
        typeIds.addAll(ids);
      }
      // Intersection: IDs that are in selected generations AND have selected types
      genIds = genIds.intersection(typeIds);
    }

    // 3. Convert IDs to PokeAPI URLs
    final List<String> allPoolUrls = [];
    for (var pokemonData in _allPokemonData) {
      final id = _getIdFromUrl(pokemonData['url']!);
      if (id != null && genIds.contains(id)) {
        allPoolUrls.add(pokemonData['url']!);
      }
    }

    final prefs = await SharedPreferences.getInstance();

    // 4. If we have some cached data, prefer it when pool is large
    // This helps with the "repetitive" issue by ensuring we don't pick
    // too many non-cached items that will just be skipped.
    final List<String> cachedUrls =
        allPoolUrls.where((url) => isCached(url, prefs)).toList();

    List<String> finalUrls;
    if (cachedUrls.length >= 10) {
      // If we have enough cached items, mix them in or favor them
      // This ensures offline play feels solid
      cachedUrls.shuffle();
      finalUrls = cachedUrls;

      // Add some non-cached ones in case user has internet now
      final nonCached =
          allPoolUrls.where((url) => !isCached(url, prefs)).toList();
      nonCached.shuffle();
      finalUrls.addAll(nonCached.take(20));
    } else {
      finalUrls = allPoolUrls;
    }

    finalUrls.shuffle();
    return finalUrls;
  }

  Future<Set<int>> _fetchIdsByType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'type_cache_$type';

    // Check cache
    final cached = prefs.getStringList(cacheKey);
    if (cached != null) {
      return cached.map(int.parse).toSet();
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/type/$type'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List pokemonList = data['pokemon'];
        final ids = pokemonList.map<int>((e) {
          final url = e['pokemon']['url'] as String;
          return _getIdFromUrl(url) ?? 0;
        }).toSet();

        // Save to cache
        await prefs.setStringList(
            cacheKey, ids.map((i) => i.toString()).toList());
        return ids;
      }
    } catch (e) {
      print('Error fetching IDs by type $type: $e');
    }
    return {};
  }

  Set<int> _getIdsForGen(int gen) {
    switch (gen) {
      case 1:
        return {for (var i = 1; i <= 151; i++) i};
      case 2:
        return {for (var i = 152; i <= 251; i++) i};
      case 3:
        return {for (var i = 252; i <= 386; i++) i};
      case 4:
        return {for (var i = 387; i <= 493; i++) i};
      case 5:
        return {for (var i = 494; i <= 649; i++) i};
      case 6:
        return {for (var i = 650; i <= 721; i++) i};
      case 7:
        return {for (var i = 722; i <= 809; i++) i};
      case 8:
        return {for (var i = 810; i <= 905; i++) i};
      case 9:
        return {for (var i = 906; i <= 1025; i++) i};
      default:
        return {};
    }
  }

  int? _getIdFromUrl(String url) {
    try {
      final segments = url.split('/');
      return int.tryParse(segments[segments.length - 2]);
    } catch (_) {
      return null;
    }
  }
}
