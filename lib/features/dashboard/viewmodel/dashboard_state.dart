import '../models/dashboard_summary.dart';

class DashboardState {
  const DashboardState({
    this.isLoading = true,
    this.summary,
    this.error,
  });

  final bool isLoading;
  final DashboardSummary? summary;
  final String? error;

  DashboardState copyWith({
    bool? isLoading,
    DashboardSummary? summary,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      error: error ?? this.error,
    );
  }
}
