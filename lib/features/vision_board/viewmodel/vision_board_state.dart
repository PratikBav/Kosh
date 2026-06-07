import '../../../database/collections/vision_item_collection.dart';

class VisionBoardState {
  final bool isLoading;
  final String? error;
  final List<VisionItemCollection> allItems;
  final List<VisionItemCollection> pinnedItems;
  final String searchQuery;
  final VisionCategory? filterCategory;
  final int? filterGoalId;

  const VisionBoardState({
    this.isLoading = false,
    this.error,
    this.allItems = const [],
    this.pinnedItems = const [],
    this.searchQuery = '',
    this.filterCategory,
    this.filterGoalId,
  });

  VisionBoardState copyWith({
    bool? isLoading,
    String? error,
    List<VisionItemCollection>? allItems,
    List<VisionItemCollection>? pinnedItems,
    String? searchQuery,
    VisionCategory? filterCategory,
    int? filterGoalId,
  }) {
    return VisionBoardState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Clear error if null is passed
      allItems: allItems ?? this.allItems,
      pinnedItems: pinnedItems ?? this.pinnedItems,
      searchQuery: searchQuery ?? this.searchQuery,
      filterCategory: filterCategory ?? this.filterCategory,
      filterGoalId: filterGoalId ?? this.filterGoalId,
    );
  }

  // Helper getters for filtered views
  List<VisionItemCollection> get filteredItems {
    var items = allItems;
    
    if (searchQuery.isNotEmpty) {
      items = items.where((item) => 
        item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        (item.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    if (filterCategory != null) {
      items = items.where((item) => item.category == filterCategory).toList();
    }

    if (filterGoalId != null) {
      items = items.where((item) => item.goalId == filterGoalId).toList();
    }
    
    return items;
  }
}
