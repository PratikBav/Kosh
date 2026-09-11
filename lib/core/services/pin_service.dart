import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'key_value_store.dart';

/// Stores and verifies the app-lock PIN.
///
/// The PIN itself is never persisted. What is stored is a PBKDF2-HMAC-SHA256
/// derivation with a per-install random salt, held in the platform keystore
/// via [KeyValueStore]. Verification is constant-time so a wrong PIN cannot be
/// narrowed down by timing.
///
/// Rate limiting lives in the security view model rather than here, because it
/// needs to survive an app restart and therefore belongs in the database.
class PinService {
  /// [iterations] is overridable so tests do not pay the production cost
  /// factor on every assertion. Leave it at the default in the app.
  PinService(this._storage, {this.iterations = defaultIterations});

  final KeyValueStore _storage;

  /// Cost factor used when setting a new PIN.
  final int iterations;

  /// Key holding the encoded derivation. The PIN is not recoverable from it.
  static const String _pinKey = 'app_lock_pin';

  static const int minPinLength = 4;
  static const int maxPinLength = 8;

  /// Raising this stays backward compatible — the iteration count is recorded
  /// in each stored hash, so PINs set by older builds keep verifying.
  static const int defaultIterations = 120000;

  static const int _saltBytes = 16;
  static const int _keyBytes = 32;
  static const String _algorithmTag = 'pbkdf2_sha256';

  /// Whether a PIN has been configured.
  Future<bool> isPinSet() async {
    final stored = await _storage.read(key: _pinKey);
    return stored != null && stored.isNotEmpty;
  }

  /// Derives and stores [pin], replacing any existing one.
  ///
  /// Throws [ArgumentError] if [pin] fails [validatePin].
  Future<void> setPin(String pin) async {
    final problem = validatePin(pin);
    if (problem != null) throw ArgumentError(problem);

    final salt = _randomSalt();
    final hash = await _derive(pin, salt, iterations);

    await _storage.write(
      key: _pinKey,
      value: _encode(
        iterations: iterations,
        salt: salt,
        hash: hash,
      ),
    );
  }

  /// Returns `true` if [pin] matches the stored PIN.
  ///
  /// Returns `false` when no PIN is set, so a missing PIN can never be
  /// mistaken for a correct one.
  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    if (stored == null || stored.isEmpty) return false;

    final parsed = _decode(stored);
    if (parsed == null) return false;

    final candidate = await _derive(pin, parsed.salt, parsed.iterations);
    return _constantTimeEquals(candidate, parsed.hash);
  }

  /// Removes the stored PIN.
  Future<void> clearPin() => _storage.delete(key: _pinKey);

  /// Returns a human-readable problem with [pin], or `null` if it is usable.
  ///
  /// Rejects the handful of PINs that make a lock decorative: repeated digits
  /// and straight runs are the first things anyone guesses.
  static String? validatePin(String pin) {
    if (pin.length < minPinLength || pin.length > maxPinLength) {
      return 'PIN must be between $minPinLength and $maxPinLength digits.';
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return 'PIN must contain digits only.';
    }
    if (_isSingleRepeatedDigit(pin)) {
      return 'Avoid a PIN made of one repeated digit.';
    }
    if (_isConsecutiveRun(pin)) {
      return 'Avoid a PIN that runs in sequence.';
    }
    return null;
  }

  static bool _isSingleRepeatedDigit(String pin) {
    return pin.split('').every((digit) => digit == pin[0]);
  }

  static bool _isConsecutiveRun(String pin) {
    var ascending = true;
    var descending = true;
    for (var i = 1; i < pin.length; i++) {
      final delta = pin.codeUnitAt(i) - pin.codeUnitAt(i - 1);
      if (delta != 1) ascending = false;
      if (delta != -1) descending = false;
    }
    return ascending || descending;
  }

  Uint8List _randomSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(_saltBytes, (_) => random.nextInt(256)),
    );
  }

  /// Runs the derivation on a background isolate — at [_iterations] it takes
  /// long enough to drop frames on the platform thread.
  Future<Uint8List> _derive(String pin, Uint8List salt, int iterations) {
    return compute(
      _pbkdf2Worker,
      (pin: pin, salt: salt, iterations: iterations, keyLength: _keyBytes),
    );
  }

  static String _encode({
    required int iterations,
    required Uint8List salt,
    required Uint8List hash,
  }) {
    return [
      _algorithmTag,
      '$iterations',
      base64Encode(salt),
      base64Encode(hash),
    ].join(r'$');
  }

  static ({int iterations, Uint8List salt, Uint8List hash})? _decode(
    String stored,
  ) {
    final parts = stored.split(r'$');
    if (parts.length != 4 || parts[0] != _algorithmTag) return null;

    final iterations = int.tryParse(parts[1]);
    if (iterations == null || iterations <= 0) return null;

    try {
      return (
        iterations: iterations,
        salt: base64Decode(parts[2]),
        hash: base64Decode(parts[3]),
      );
    } on FormatException {
      return null;
    }
  }

  /// Compares without an early exit, so elapsed time does not reveal how many
  /// leading bytes were correct.
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}

/// PBKDF2-HMAC-SHA256, as specified in RFC 8018.
///
/// Top-level so it can be handed to [compute]. Only a single output block is
/// produced, which is all that is needed while the key length does not exceed
/// SHA-256's 32-byte digest.
@visibleForTesting
Uint8List pbkdf2Sha256({
  required String password,
  required Uint8List salt,
  required int iterations,
  required int keyLength,
}) {
  assert(keyLength <= 32, 'Only one output block is derived.');

  final hmac = Hmac(sha256, utf8.encode(password));

  // U1 = HMAC(password, salt || INT_32_BE(1))
  var block = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
  final accumulator = List<int>.from(block);

  // Un = HMAC(password, Un-1), accumulated by XOR.
  for (var i = 1; i < iterations; i++) {
    block = hmac.convert(block).bytes;
    for (var j = 0; j < accumulator.length; j++) {
      accumulator[j] ^= block[j];
    }
  }

  return Uint8List.fromList(accumulator.sublist(0, keyLength));
}

Uint8List _pbkdf2Worker(
  ({String pin, Uint8List salt, int iterations, int keyLength}) args,
) {
  return pbkdf2Sha256(
    password: args.pin,
    salt: args.salt,
    iterations: args.iterations,
    keyLength: args.keyLength,
  );
}
