/// Named route path constants for GoRouter.
///
/// All route strings are defined here to avoid magic strings.
/// Usage: `context.goNamed(RouteConstants.dashboard)`
class RouteConstants {
  RouteConstants._();

  // ── Route Names ───────────────────────────────────────────────────
  static const String dashboard = 'dashboard';
  static const String transactions = 'transactions';
  static const String goals = 'goals';
  static const String analytics = 'analytics';
  static const String settings = 'settings';

  // ── Route Paths ───────────────────────────────────────────────────
  static const String dashboardPath = '/';
  static const String transactionsPath = '/transactions';
  static const String goalsPath = '/goals';
  static const String analyticsPath = '/analytics';
  static const String settingsPath = '/settings';
}
