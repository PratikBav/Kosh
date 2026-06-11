/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Kosh';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Futuristic personal finance & goal tracking';

  static const String databaseName = 'kosh_db';
  static const int databaseVersion = 1;

  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  static const int maxTransactionNoteLength = 200;
  static const int maxGoalNameLength = 50;
  static const int maxCategoryNameLength = 30;
}
