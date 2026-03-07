import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  final List<int> selectedGenerations;
  final List<String> selectedTypes;

  FilterState({
    required this.selectedGenerations,
    required this.selectedTypes,
  });

  FilterState copyWith({
    List<int>? selectedGenerations,
    List<String>? selectedTypes,
  }) {
    return FilterState(
      selectedGenerations: selectedGenerations ?? this.selectedGenerations,
      selectedTypes: selectedTypes ?? this.selectedTypes,
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

  void resetFilters() {
    state = FilterState(
      selectedGenerations: [1, 2, 3, 4, 5, 6, 7, 8, 9],
      selectedTypes: [],
    );
  }
}

final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});
