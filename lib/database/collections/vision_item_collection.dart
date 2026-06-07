import 'package:isar/isar.dart';

part 'vision_item_collection.g.dart';

enum VisionCategory {
  travel('Travel'),
  education('Education'),
  vehicle('Vehicle'),
  home('Home'),
  technology('Technology'),
  business('Business'),
  lifestyle('Lifestyle'),
  investment('Investment'),
  personal('Personal'),
  other('Other');

  final String label;
  const VisionCategory(this.label);
}

@collection
class VisionItemCollection {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  String? description;

  /// Absolute or relative path to the image stored in app directory
  String? imagePath;

  /// Motivational quote associated with this vision item
  String? quote;

  /// ID of the goal this vision item is linked to
  @Index()
  int? goalId;

  @enumerated
  late VisionCategory category;

  late DateTime createdAt;
  late DateTime updatedAt;

  @Index()
  bool isPinned = false;
}
