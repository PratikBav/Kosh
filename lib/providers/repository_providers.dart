import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/transaction_repository.dart';
import '../database/repositories/goals_repository.dart';
import 'database_providers.dart';

/// Provides the [TransactionRepository].
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TransactionRepository(isar);
});

/// Provides the [GoalsRepository].
final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return GoalsRepository(isar);
});
