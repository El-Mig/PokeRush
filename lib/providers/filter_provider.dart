import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  final List<int> selectedGenerations;
  final List<String> selectedTypes;
  final String difficulty; // 'Normal', 'Expert'
  final String category; // 'All', 'Starters', 'Legendaries'

  FilterState({
    required this.selectedGenerations,
    required this.selectedTypes,
    this.difficulty = 'Normal',
    this.category = 'All',
  });

  FilterState copyWith({
    List<int>? selectedGenerations,
    List<String>? selectedTypes,
    String? difficulty,
    String? category,
  }) {
    return FilterState(
      selectedGenerations: selectedGenerations ?? this.selectedGenerations,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier()
      : super(FilterState(
          selectedGenerations: [1, 2, 3, 4, 5, 6, 7, 8, 9],
          selectedTypes: [], // Empty means all types
        ));

  void toggleGeneration(int gen) {
    final current = state.selectedGenerations;
    if (current.contains(gen)) {
      if (current.length > 1) {
        state = state.copyWith(
          selectedGenerations: current.where((g) => g != gen).toList(),
        );
      }
    } else {
      state = state.copyWith(
        selectedGenerations: [...current, gen],
      );
    }
  }

  void toggleType(String type) {
    final current = state.selectedTypes;
    if (current.contains(type)) {
      state = state.copyWith(
        selectedTypes: current.where((t) => t != type).toList(),
      );
    } else {
      state = state.copyWith(
        selectedTypes: [...current, type],
      );
    }
  }

  void setDifficulty(String diff) {
    state = state.copyWith(difficulty: diff);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void resetFilters() {
    state = FilterState(
      selectedGenerations: [1, 2, 3, 4, 5, 6, 7, 8, 9],
      selectedTypes: [],
      difficulty: 'Normal',
      category: 'All',
    );
  }
}

final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});
