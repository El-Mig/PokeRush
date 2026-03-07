import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/pokedex_provider.dart';
import '../providers/game_provider.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  String _searchQuery = "";
  int? _selectedGen;

  final Map<int, List<int>> _genRanges = {
    1: [1, 151],
    2: [152, 251],
    3: [252, 386],
    4: [387, 493],
    5: [494, 649],
    6: [650, 721],
    7: [722, 809],
    8: [810, 905],
    9: [906, 1025],
  };

  @override
  void initState() {
    super.initState();
    // Ensure pokemon data is loaded for search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    await ref.read(pokemonServiceProvider).initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final caughtPokemon = ref.watch(pokedexProvider);
    final pokemonService = ref.read(pokemonServiceProvider);
    final allNames = pokemonService.allPokemonData;

    // Filter IDs
    List<int> filteredIds = [];
    for (int i = 1; i <= 1025; i++) {
      bool matchesSearch = true;
      bool matchesGen = true;

      if (_searchQuery.isNotEmpty) {
        String name = "";
        // Try to find name in allNames (which is 0-indexed)
        if (i <= allNames.length) {
          name = allNames[i - 1]['name'] ?? "";
        }

        // If name is still empty, search might fail to find anything
        // which is why initialization is critical
        if (!name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          matchesSearch = false;
        }
      }

      if (_selectedGen != null) {
        final range = _genRanges[_selectedGen]!;
        if (i < range[0] || i > range[1]) {
          matchesGen = false;
        }
      }

      if (matchesSearch && matchesGen) {
        filteredIds.add(i);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('POKÉDEX'),
        backgroundColor: const Color(0xFF3B1010),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar por nombre...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Generation Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 10, // All + 9 Gens
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final gen = isAll ? null : index;
                final isSelected = _selectedGen == gen;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(isAll ? "Todos" : "Gen $gen"),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedGen = selected ? gen : null);
                    },
                    backgroundColor: Colors.white.withOpacity(0.05),
                    selectedColor: const Color(0xFFD4A017),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MOSTRANDO: ${filteredIds.length}',
                  style: const TextStyle(
                      color: Color(0xFFD4A017),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  'CAPTURADOS: ${caughtPokemon.length}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
              ],
            ),
          ),

          Expanded(
            child: allNames.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFD4A017)),
                        SizedBox(height: 16),
                        Text("Cargando datos...",
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  )
                : filteredIds.isEmpty
                    ? const Center(
                        child: Text("No se encontraron Pokémon",
                            style: TextStyle(color: Colors.white38)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filteredIds.length,
                        itemBuilder: (context, index) {
                          final id = filteredIds[index];
                          final entry = caughtPokemon[id];
                          final isCaught = entry != null;

                          return _PokedexTile(
                            id: id,
                            entry: entry,
                            isCaught: isCaught,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PokedexTile extends StatelessWidget {
  final int id;
  final PokedexEntry? entry;
  final bool isCaught;

  const _PokedexTile({
    required this.id,
    this.entry,
    required this.isCaught,
  });

  String _getSpriteUrl(bool shiny) {
    if (shiny) {
      return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/$id.png';
    }
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCaught
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCaught
              ? const Color(0xFFD4A017).withOpacity(0.3)
              : Colors.white10,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '#${id.toString().padLeft(3, '0')}',
            style: TextStyle(
              color: isCaught ? const Color(0xFFD4A017) : Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isCaught ? 1.0 : 0.1,
                  child: CachedNetworkImage(
                    imageUrl: _getSpriteUrl(false),
                    placeholder: (context, url) => const SizedBox(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.help_outline, color: Colors.white10),
                  ),
                ),
                if (isCaught && entry!.hasShiny)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.amber, size: 14),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              isCaught ? entry!.name : '???',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isCaught ? Colors.white : Colors.white24,
                fontSize: 10,
                fontWeight: isCaught ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
