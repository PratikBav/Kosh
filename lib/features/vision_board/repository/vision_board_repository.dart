import 'package:isar/isar.dart';
import '../../../database/collections/vision_item_collection.dart';

class VisionBoardRepository {
  final Isar isar;

  VisionBoardRepository(this.isar);

  Future<List<VisionItemCollection>> getAllVisionItems() async {
    return await isar.visionItemCollections.where().sortByCreatedAtDesc().findAll();
  }

  Future<List<VisionItemCollection>> getPinnedItems() async {
    return await isar.visionItemCollections
        .where()
        .filter()
        .isPinnedEqualTo(true)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<void> addVisionItem(VisionItemCollection item) async {
    await isar.writeTxn(() async {
      await isar.visionItemCollections.put(item);
    });
  }

  Future<void> updateVisionItem(VisionItemCollection item) async {
    await isar.writeTxn(() async {
      item.updatedAt = DateTime.now();
      await isar.visionItemCollections.put(item);
    });
  }

  Future<void> deleteVisionItem(int id) async {
    await isar.writeTxn(() async {
      await isar.visionItemCollections.delete(id);
    });
  }
}
