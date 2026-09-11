import 'package:flutter_test/flutter_test.dart';
import 'package:kosh/core/utils/change_debouncer.dart';

void main() {
  group('ChangeDebouncer', () {
    test('collapses a burst of calls into a single run', () async {
      final debouncer = ChangeDebouncer(
        delay: const Duration(milliseconds: 20),
      );
      addTearDown(debouncer.dispose);

      var runs = 0;

      // Stands in for three Isar collections reporting one user edit.
      debouncer.run(() => runs++);
      debouncer.run(() => runs++);
      debouncer.run(() => runs++);

      expect(runs, 0, reason: 'nothing should fire synchronously');

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(runs, 1);
    });

    test('runs again for a separate burst', () async {
      final debouncer = ChangeDebouncer(
        delay: const Duration(milliseconds: 20),
      );
      addTearDown(debouncer.dispose);

      var runs = 0;

      debouncer.run(() => runs++);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      debouncer.run(() => runs++);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(runs, 2);
    });

    test('dispose cancels a pending run', () async {
      final debouncer = ChangeDebouncer(
        delay: const Duration(milliseconds: 20),
      );

      var runs = 0;
      debouncer.run(() => runs++);
      debouncer.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(runs, 0);
    });

    test('dispose is safe to call twice', () {
      final debouncer = ChangeDebouncer();
      debouncer.dispose();
      expect(debouncer.dispose, returnsNormally);
    });
  });
}
