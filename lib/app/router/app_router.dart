import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_constants.dart';
import '../../features/dashboard/view/dashboard_view.dart';
import '../../features/transactions/view/transactions_view.dart';
import '../../features/goals/view/goals_view.dart';
import '../../features/analytics/view/analytics_view.dart';
import '../../features/settings/view/settings_view.dart';
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
                builder: (context, state) => const DashboardView(),
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
                builder: (context, state) => const AnalyticsView(),
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
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
