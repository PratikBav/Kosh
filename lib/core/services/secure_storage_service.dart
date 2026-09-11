import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'key_value_store.dart';

/// Encrypted key-value storage for sensitive data (PINs, tokens, flags).
///
/// Wraps [FlutterSecureStorage] with convenience methods.
/// All data is encrypted at rest using platform-specific mechanisms.
class SecureStorageService implements KeyValueStore {
  SecureStorageService();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Writes a value to secure storage.
  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// Reads a value from secure storage.
  ///
  /// Returns `null` if the key does not exist.
  @override
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  /// Deletes a specific key from secure storage.
  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// Checks if a key exists in secure storage.
  @override
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  /// Deletes all keys from secure storage.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
