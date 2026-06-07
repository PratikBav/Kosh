import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_constants.dart';
import '../../features/analytics/view/analytics_screen.dart';
import '../../features/dashboard/view/dashboard_screen.dart';
import '../../features/transactions/view/add_transaction_screen.dart';
import '../../features/transactions/view/transaction_details_screen.dart';
import '../../features/transactions/view/transactions_view.dart';
import '../../features/goals/view/goals_view.dart';
import '../../features/goals/view/add_goal_screen.dart';
import '../../features/goals/view/goal_details_screen.dart';
import '../../features/goals/view/add_contribution_screen.dart';
import '../../features/gamification/view/achievements_screen.dart';
import '../../features/gamification/view/profile_progress_screen.dart';
import '../../features/settings/view/settings_view.dart';
import '../../features/security/view/security_settings_screen.dart';

import '../../features/security/view/backup_screen.dart';
import '../../features/security/view/privacy_settings_screen.dart';
import '../../features/vision_board/view/vision_board_screen.dart';
import '../../features/vision_board/view/create_vision_item_screen.dart';
import '../../features/vision_board/view/vision_item_detail_screen.dart';
import 'navigation_shell.dart';

/// GoRouter configuration for the Kosh application.
///
/// Uses [StatefulShellRoute.indexedStack] for persistent bottom
/// navigation across five main tabs. Each branch maintains its
/// own navigation stack.
class AppRouter {
  AppRouter._();

  /// Navigator keys for each branch — allows independent navigation stacks.
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _dashboardNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'dashboard');
  static final _transactionsNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'transactions');
  static final _goalsNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'goals');
  static final _visionBoardNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'vision');
  static final _analyticsNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'analytics');
  static final _settingsNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'settings');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.dashboardPath,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // ── Dashboard ─────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: RouteConstants.dashboardPath,
                name: RouteConstants.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // ── Transactions ──────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _transactionsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteConstants.transactionsPath,
                name: RouteConstants.transactions,
                builder: (context, state) => const TransactionsView(),
                routes: [
                  GoRoute(
                    path: RouteConstants.addTransactionPath,
                    name: RouteConstants.addTransaction,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      // Pass transaction ID if editing
                      final id = state.uri.queryParameters['id'];
                      return AddTransactionScreen(
                        transactionId: id != null ? int.tryParse(id) : null,
                      );
                    },
                  ),
                  GoRoute(
                    path: RouteConstants.transactionDetailsPath,
                    name: RouteConstants.transactionDetails,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return TransactionDetailsScreen(transactionId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // ── Goals ─────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _goalsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteConstants.goalsPath,
                name: RouteConstants.goals,
                builder: (context, state) => const GoalsView(),
                routes: [
                  GoRoute(
                    path: RouteConstants.addGoalPath,
                    name: RouteConstants.addGoal,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const AddGoalScreen(),
                  ),
                  GoRoute(
                    path: RouteConstants.goalDetailsPath,
                    name: RouteConstants.goalDetails,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return GoalDetailsScreen(goalId: id);
                    },
                    routes: [
                      GoRoute(
                        path: RouteConstants.addContributionPath,
                        name: RouteConstants.addContribution,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return AddContributionScreen(goalId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Vision Board ──────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _visionBoardNavigatorKey,
            routes: [
              GoRoute(
                path: RouteConstants.visionBoardPath,
                name: RouteConstants.visionBoard,
                builder: (context, state) => const VisionBoardScreen(),
                routes: [
                  GoRoute(
                    path: RouteConstants.createVisionItemPath,
                    name: RouteConstants.createVisionItem,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const CreateVisionItemScreen(),
                  ),
                  GoRoute(
                    path: RouteConstants.visionItemDetailsPath,
                    name: RouteConstants.visionItemDetails,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return VisionItemDetailScreen(itemId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // ── Analytics ─────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _analyticsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteConstants.analyticsPath,
                name: RouteConstants.analytics,
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),

          // ── Settings ──────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteConstants.settingsPath,
                name: RouteConstants.settings,
                builder: (context, state) => const SettingsView(),
                routes: [
                  GoRoute(
                    path: RouteConstants.securitySettingsPath,
                    name: RouteConstants.securitySettings,
                    builder: (context, state) => const SecuritySettingsScreen(),
                  ),

                  GoRoute(
                    path: RouteConstants.backupPath,
                    name: RouteConstants.backup,
                    builder: (context, state) => const BackupScreen(),
                  ),
                  GoRoute(
                    path: RouteConstants.privacyPath,
                    name: RouteConstants.privacy,
                    builder: (context, state) => const PrivacySettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.profileProgressPath,
        name: RouteConstants.profileProgress,
        builder: (context, state) => const ProfileProgressScreen(),
        routes: [
          GoRoute(
            path: RouteConstants.achievementsPath,
            name: RouteConstants.achievements,
            builder: (context, state) => const AchievementsScreen(),
          ),
        ],
      ),
    ],
  );
}
