// lib/core/cache/ttl_cache.dart
// WHY: Many screens re-fetch the same lookup data (tags, members, sections)
//      on every build. A tiny TTL cache kills the redundant Firestore reads
//      without adding any dependency. Designed to be Riverpod-friendly:
//      create one instance per provider and let the cache live as long as
//      the provider is watched.

import 'dart:async';

/// A single cached entry with its expiration timestamp.
class _CacheEntry<V> {
  final V value;
  final DateTime expiresAt;

  const _CacheEntry(this.value, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Minimal TTL cache. Keys are strings (collection paths, query ids).
/// Eviction is lazy — entries are checked on read. A periodic sweep runs
/// every [sweepInterval] to keep memory bounded in long-lived sessions.
class TtlCache<K, V> {
  TtlCache({
    this.defaultTtl = const Duration(minutes: 5),
    this.maxEntries = 256,
    this.sweepInterval = const Duration(minutes: 2),
  }) {
    _scheduleSweep();
  }

  final Duration defaultTtl;
  final int maxEntries;
  final Duration sweepInterval;

  final Map<K, _CacheEntry<V>> _store = {};
  Timer? _sweepTimer;
  bool _disposed = false;

  /// Returns the cached value if present and not expired, else null.
  V? get(K key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  /// Stores [value] under [key] with the default TTL (or [ttl] if given).
  void put(K key, V value, {Duration? ttl}) {
    if (_disposed) return;
    if (_store.length >= maxEntries && !_store.containsKey(key)) {
      _evictOldest();
    }
    final expiresAt = DateTime.now().add(ttl ?? defaultTtl);
    _store[key] = _CacheEntry(value, expiresAt);
  }

  /// Like [get] but populates the cache from [loader] on miss.
  Future<V> getOrLoad(K key, Future<V> Function() loader, {Duration? ttl}) async {
    final cached = get(key);
    if (cached != null) return cached;
    final fresh = await loader();
    put(key, fresh, ttl: ttl);
    return fresh;
  }

  /// Invalidates a single key.
  void invalidate(K key) => _store.remove(key);

  /// Clears the whole cache.
  void clear() => _store.clear();

  /// Releases the sweep timer. Call when the owning provider is disposed.
  void dispose() {
    _disposed = true;
    _sweepTimer?.cancel();
    _sweepTimer = null;
    _store.clear();
  }

  void _scheduleSweep() {
    _sweepTimer = Timer.periodic(sweepInterval, (_) => _sweep());
  }

  void _sweep() {
    _store.removeWhere((_, entry) => entry.isExpired);
  }

  void _evictOldest() {
    if (_store.isEmpty) return;
    K? oldestKey;
    DateTime? oldestAt;
    for (final entry in _store.entries) {
      if (oldestAt == null || entry.value.expiresAt.isBefore(oldestAt)) {
        oldestAt = entry.value.expiresAt;
        oldestKey = entry.key;
      }
    }
    if (oldestKey != null) _store.remove(oldestKey);
  }
}
