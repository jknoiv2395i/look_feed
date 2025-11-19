class _CacheEntry {
  _CacheEntry(this.value, this.expiresAt);

  final dynamic value;
  final DateTime? expiresAt;
}

class CacheService {
  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};

  Future<void> put(String key, dynamic value, {Duration? ttl}) async {
    final DateTime? expiresAt = ttl != null ? DateTime.now().add(ttl) : null;
    _cache[key] = _CacheEntry(value, expiresAt);
  }

  Future<T?> get<T>(String key) async {
    final _CacheEntry? entry = _cache[key];
    if (entry == null) {
      return null;
    }
    if (entry.expiresAt != null && entry.expiresAt!.isBefore(DateTime.now())) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T?;
  }

  Future<void> clearExpired() async {
    final DateTime now = DateTime.now();
    _cache.removeWhere((String key, _CacheEntry entry) {
      return entry.expiresAt != null && entry.expiresAt!.isBefore(now);
    });
  }

  Future<void> clearAll() async {
    _cache.clear();
  }
}
