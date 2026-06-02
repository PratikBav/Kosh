import 'package:isar/isar.dart';

part 'xp_record_collection.g.dart';

@collection
class XpRecordCollection {
  Id id = Isar.autoIncrement;

  late int amount;
  
  late String reason;
  
  late DateTime timestamp;
}
