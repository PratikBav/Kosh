import 'dart:async';

/// Coalesces a burst of change notifications into a single callback.
///
/// Isar reports each collection separately, so one user action can fan out:
/// saving a goal contribution writes the contribution *and* the goal, and a
/// screen watching both would reload twice for one edit. Debouncing collapses
/// the burst into one refresh.
///
/// The delay is short enough to stay imperceptible and long enough to absorb
/// the writes of a single transaction.
class ChangeDebouncer {
  ChangeDebouncer({this.delay = const Duration(milliseconds: 120)});

  final Duration delay;

  Timer? _timer;

  /// Schedules [action], replacing any call still pending.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels a pending call. Safe to call more than once.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
