import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../database/collections/vision_item_collection.dart';
import '../../../providers/repository_providers.dart';
import '../repository/vision_board_repository.dart';
import 'vision_board_state.dart';

final visionBoardViewModelProvider =
    StateNotifierProvider<VisionBoardViewModel, VisionBoardState>((ref) {
  final repository = ref.watch(visionBoardRepositoryProvider);
  return VisionBoardViewModel(repository);
});

class VisionBoardViewModel extends StateNotifier<VisionBoardState> {
  final VisionBoardRepository _repository;

  VisionBoardViewModel(this._repository) : super(const VisionBoardState()) {
    loadVisionItems();
  }

  Future<void> loadVisionItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _repository.getAllVisionItems();
      final pinnedItems = await _repository.getPinnedItems();
      
      state = state.copyWith(
        isLoading: false,
        allItems: items,
        pinnedItems: pinnedItems,
        error: null, // Clear error
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addVisionItem({
    required String title,
    String? description,
    String? originalImagePath,
    String? quote,
    int? goalId,
    required VisionCategory category,
  }) async {
    try {
      String? localImagePath;
      if (originalImagePath != null && originalImagePath.isNotEmpty) {
        localImagePath = await _saveImageLocally(originalImagePath);
      }

      final newItem = VisionItemCollection()
        ..title = title
        ..description = description
        ..imagePath = localImagePath
        ..quote = quote
        ..goalId = goalId
        ..category = category
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isPinned = false;

      await _repository.addVisionItem(newItem);
      await loadVisionItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateVisionItem(VisionItemCollection item, {String? newImagePath}) async {
    try {
      if (newImagePath != null && newImagePath.isNotEmpty && newImagePath != item.imagePath) {
        final newLocalPath = await _saveImageLocally(newImagePath);
        // Optionally delete old image if it exists to save space
        if (item.imagePath != null) {
          final oldFile = File(item.imagePath!);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        }
        item.imagePath = newLocalPath;
      }

      await _repository.updateVisionItem(item);
      await loadVisionItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> togglePin(VisionItemCollection item) async {
    try {
      if (!item.isPinned) {
        // Checking limit before pinning
        final pinnedCount = state.pinnedItems.length;
        if (pinnedCount >= 3) {
          state = state.copyWith(error: 'Maximum of 3 dreams can be pinned.');
          return;
        }
      }

      item.isPinned = !item.isPinned;
      await _repository.updateVisionItem(item);
      await loadVisionItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteVisionItem(VisionItemCollection item) async {
    try {
      if (item.imagePath != null) {
        final file = File(item.imagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _repository.deleteVisionItem(item.id);
      await loadVisionItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<String> _saveImageLocally(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Source image not found');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final visionsDir = Directory('${appDir.path}/visions');
    if (!await visionsDir.exists()) {
      await visionsDir.create(recursive: true);
    }

    final baseName = sourcePath.split('/').last.split('\\').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$baseName';
    final targetPath = '${visionsDir.path}/$fileName';
    
    await sourceFile.copy(targetPath);
    return targetPath;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(VisionCategory? category) {
    state = state.copyWith(filterCategory: category);
  }
  
  void setGoalFilter(int? goalId) {
    state = state.copyWith(filterGoalId: goalId);
  }

  void clearFilters() {
    state = VisionBoardState(
      isLoading: state.isLoading,
      allItems: state.allItems,
      pinnedItems: state.pinnedItems,
      error: state.error,
    );
  }
}
