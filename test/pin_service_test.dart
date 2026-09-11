import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosh/core/services/key_value_store.dart';
import 'package:kosh/core/services/pin_service.dart';

/// In-memory stand-in for the platform keystore.
class FakeKeyValueStore implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<bool> containsKey({required String key}) async =>
      values.containsKey(key);

  @override
  Future<void> delete({required String key}) async => values.remove(key);

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

String hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeKeyValueStore store;
  late PinService service;

  setUp(() {
    store = FakeKeyValueStore();
    // A low cost factor keeps the suite fast; the derivation itself is
    // identical to production, which runs at PinService.defaultIterations.
    service = PinService(store, iterations: 1000);
  });

  group('pbkdf2Sha256', () {
    // Published PBKDF2-HMAC-SHA256 vectors for password "password", salt
    // "salt". If this implementation ever drifts, these catch it.
    test('matches known vectors', () {
      final salt = Uint8List.fromList(utf8.encode('salt'));

      expect(
        hex(pbkdf2Sha256(
          password: 'password',
          salt: salt,
          iterations: 1,
          keyLength: 32,
        )),
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
      );

      expect(
        hex(pbkdf2Sha256(
          password: 'password',
          salt: salt,
          iterations: 2,
          keyLength: 32,
        )),
        'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43',
      );

      expect(
        hex(pbkdf2Sha256(
          password: 'password',
          salt: salt,
          iterations: 4096,
          keyLength: 32,
        )),
        'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
      );
    });
  });

  group('set and verify', () {
    test('accepts the correct PIN and rejects others', () async {
      await service.setPin('1379');

      expect(await service.verifyPin('1379'), isTrue);
      expect(await service.verifyPin('1378'), isFalse);
      expect(await service.verifyPin('13790'), isFalse);
      expect(await service.verifyPin(''), isFalse);
    });

    test('never stores the PIN in recoverable form', () async {
      await service.setPin('8524');

      final stored = store.values.values.single;
      expect(stored, isNot(contains('8524')));
      expect(stored, startsWith('pbkdf2_sha256\$1000\$'));
    });

    test('salts each PIN so identical PINs hash differently', () async {
      await service.setPin('8524');
      final first = store.values.values.single;

      await service.setPin('8524');
      final second = store.values.values.single;

      expect(first, isNot(second));
    });

    test('verification fails when no PIN is set', () async {
      expect(await service.isPinSet(), isFalse);
      expect(await service.verifyPin('1379'), isFalse);
    });

    test('clearPin removes the stored derivation', () async {
      await service.setPin('1379');
      expect(await service.isPinSet(), isTrue);

      await service.clearPin();

      expect(await service.isPinSet(), isFalse);
      expect(await service.verifyPin('1379'), isFalse);
    });

    test('a PIN set at a different cost factor still verifies', () async {
      // Guards the upgrade path: the iteration count travels with the hash.
      await PinService(store, iterations: 500).setPin('1379');

      final atNewCost = PinService(store, iterations: 5000);
      expect(await atNewCost.verifyPin('1379'), isTrue);
    });

    test('a corrupted stored value fails closed', () async {
      await service.setPin('1379');
      store.values.updateAll((key, value) => 'not-a-valid-hash');

      expect(await service.verifyPin('1379'), isFalse);
    });
  });

  group('validatePin', () {
    test('accepts a reasonable PIN', () {
      expect(PinService.validatePin('1379'), isNull);
      expect(PinService.validatePin('80421'), isNull);
    });

    test('rejects PINs that are too short or too long', () {
      expect(PinService.validatePin('137'), contains('between'));
      expect(PinService.validatePin('137913791'), contains('between'));
    });

    test('rejects non-digits', () {
      expect(PinService.validatePin('13a9'), contains('digits only'));
    });

    test('rejects repeated and sequential PINs', () {
      expect(PinService.validatePin('1111'), contains('repeated digit'));
      expect(PinService.validatePin('1234'), contains('sequence'));
      expect(PinService.validatePin('9876'), contains('sequence'));
    });

    test('setPin refuses a PIN that fails validation', () {
      expect(() => service.setPin('1234'), throwsArgumentError);
    });
  });
}
