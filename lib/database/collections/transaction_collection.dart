import 'package:isar/isar.dart';

import '../../features/transactions/models/transaction_category.dart';
import '../../features/transactions/models/transaction_type.dart';

part 'transaction_collection.g.dart';

/// Database entity for a single transaction.
@collection
class TransactionCollection {
  Id id = Isar.autoIncrement;

  late String title;
  
  late double amount;

  @Enumerated(EnumType.name)
  @Index()
  late TransactionType type;

  @Enumerated(EnumType.name)
  @Index()
  late TransactionCategory category;

  @Index()
  late DateTime date;

  String? notes;

  late DateTime createdAt;
  
  late DateTime updatedAt;
}
