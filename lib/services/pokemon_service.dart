import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
      // Validate that the cache is complete (at least 1000 Pokemon)
      if (decoded.length >= 1000) {
        _allPokemonData =
            decoded.map((e) => Map<String, String>.from(e)).toList();
        _totalCount = _allPokemonData.length;
        print('DEBUG: Loaded ${_allPokemonData.length} Pokemon from cache');
        return;
      } else {
        print('DEBUG: Incomplete cache detected. Forcing a fresh fetch.');
      }
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

        // Try to save to cache for offline use, but ignore if it fails (QuotaExceededError on Web)
        try {
          await prefs.setString(cacheKey, response.body);
        } catch (cacheError) {
          print(
              'DEBUG: Could not cache $url (cache full or error): $cacheError');
        }

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

  Future<void> downloadEntirePokedex(
      void Function(int current, int total) onProgress) async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();

    // We will assume 1025 for now, or use _totalCount if initialized
    final total = _totalCount > 0 ? _totalCount : 1025;
    final limit = total > 1025 ? 1025 : total; // Limit to Gen 9 for now

    int current = 0;

    for (int i = 1; i <= limit; i++) {
      final url = '$_baseUrl/pokemon/$i/';
      final cacheKey = 'pokemon_detail_$url';

      try {
        String? responseBody;

        // 1. Check if we already have the JSON
        if (prefs.containsKey(cacheKey)) {
          responseBody = prefs.getString(cacheKey);
        } else {
          // Fetch JSON
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            responseBody = response.body;
            try {
              await prefs.setString(cacheKey, responseBody);
            } catch (e) {
              print('DEBUG: SharedPreferences Quota error at Pokemon ID $i');
              // We could stop the download, but let's try to continue
            }
          }
        }

        // 2. Pre-cache the image
        if (responseBody != null) {
          final data = json.decode(responseBody);
          final pokemon = Pokemon.fromJson(data);

          try {
            await DefaultCacheManager().downloadFile(pokemon.currentSpriteUrl);
          } catch (e) {
            print('DEBUG: Failed to cache image for Pokemon ID $i: $e');
          }
        }
      } catch (e) {
        print('DEBUG: Error downloading Pokemon ID $i: $e');
      }

      current++;
      onProgress(current, limit);

      // Add a tiny delay to give the UI thread a breathing room
      // and prevent API rate limiting
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<List<String>> preparePool({
    required List<int> selectedGens,
    required List<String> selectedTypes,
    String difficulty = 'Normal',
    String category = 'All',
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
      genIds = genIds.intersection(typeIds);
    }

    // 3. Filter by Category
    if (category != 'All') {
      final categoryIds = _getIdsForCategory(category);
      genIds = genIds.intersection(categoryIds);
    }

    // 4. Filter by Difficulty (Popularity)
    if (difficulty == 'Normal') {
      // In the future, we could filter out obscure middle evolutions here.
      // For now, allow all explicitly selected generations to appear.
    }

    // 5. Convert IDs to PokeAPI URLs
    final List<String> allPoolUrls = [];
    for (var pokemonData in _allPokemonData) {
      final id = _getIdFromUrl(pokemonData['url']!);
      if (id != null && genIds.contains(id)) {
        allPoolUrls.add(pokemonData['url']!);
      }
    }

    if (allPoolUrls.isEmpty) return [];

    // 6. Ensure the queue is long enough for extended play (Survival)
    List<String> finalUrls = [];
    const targetSize = 300;
    while (finalUrls.length < targetSize) {
      var copy = List<String>.from(allPoolUrls);
      copy.shuffle();
      finalUrls.addAll(copy);
    }

    // 7. Pull a random cached item to the very front for instant startup
    final prefs = await SharedPreferences.getInstance();

    final cachedIndices = <int>[];
    for (int i = 0; i < finalUrls.length; i++) {
      if (isCached(finalUrls[i], prefs)) {
        cachedIndices.add(i);
      }
    }

    if (cachedIndices.isNotEmpty) {
      cachedIndices.shuffle();
      final selectedIndex = cachedIndices.first;

      if (selectedIndex > 0) {
        final cachedUrl = finalUrls.removeAt(selectedIndex);
        finalUrls.insert(0, cachedUrl);
      }
    }

    return finalUrls;
  }

  Set<int> _getIdsForCategory(String category) {
    switch (category) {
      case 'Starters':
        return {
          1, 4, 7, // Gen 1
          152, 155, 158, // Gen 2
          252, 255, 258, // Gen 3
          387, 390, 393, // Gen 4
          495, 498, 501, // Gen 5
          650, 653, 656, // Gen 6
          722, 725, 728, // Gen 7
          810, 813, 816, // Gen 8
          906, 909, 912, // Gen 9
          // Evolutions
          2, 3, 5, 6, 8, 9,
          153, 154, 156, 157, 159, 160,
          253, 254, 256, 257, 259, 260,
          388, 389, 391, 392, 394, 395,
          496, 497, 499, 500, 502, 503,
          651, 652, 654, 655, 657, 658,
          723, 724, 726, 727, 729, 730,
          811, 812, 814, 815, 817, 818,
          907, 908, 910, 911, 913, 914,
        };
      case 'Legendaries':
        return {
          144, 145, 146, 150, 151, // Gen 1
          243, 244, 245, 249, 250, 251, // Gen 2
          377, 378, 379, 380, 381, 382, 383, 384, 385, 386, // Gen 3
          480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492,
          493, // Gen 4
          494, 638, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648,
          649, // Gen 5
          716, 717, 718, 719, 720, 721, // Gen 6
          772,
          773,
          785,
          786,
          787,
          788,
          789,
          790,
          791,
          792,
          793,
          794,
          795,
          796,
          797,
          798,
          799,
          800,
          801,
          802,
          803,
          804,
          805,
          806,
          807,
          808,
          809, // Gen 7
          888, 889, 890, 891, 892, 893, 894, 895, 896, 897, 898, // Gen 8
          1001, 1002, 1003, 1004, 1007, 1008,
          1010 // Gen 9 (Incomplete but representative)
        };
      default:
        return {};
    }
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

        // Try to save to cache, but ignore if it fails
        try {
          await prefs.setStringList(
              cacheKey, ids.map((i) => i.toString()).toList());
        } catch (e) {
          print('DEBUG: Could not cache type $type list (cache full): $e');
        }

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
