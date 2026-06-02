import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/transaction_repository.dart';
import '../database/repositories/goals_repository.dart';
import '../features/dashboard/repository/dashboard_repository.dart';
import '../features/analytics/repository/analytics_repository.dart';
import '../features/gamification/repository/gamification_repository.dart';
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

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final txRepo = ref.watch(transactionRepositoryProvider);
  final goalsRepo = ref.watch(goalsRepositoryProvider);
  return DashboardRepository(
    transactionsRepository: txRepo,
    goalsRepository: goalsRepo,
  );
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final txRepo = ref.watch(transactionRepositoryProvider);
  final goalsRepo = ref.watch(goalsRepositoryProvider);
  return AnalyticsRepository(
    transactionsRepository: txRepo,
    goalsRepository: goalsRepo,
  );
});

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return GamificationRepository(isar);
});
