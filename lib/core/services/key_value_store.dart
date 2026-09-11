/// A minimal string key-value store.
///
/// [SecureStorageService] is the production implementation, backed by the
/// platform keystore. The interface exists so logic that depends on secure
/// storage — PIN hashing in particular — can be exercised in tests without a
/// platform channel.
abstract interface class KeyValueStore {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});

  Future<bool> containsKey({required String key});
}
