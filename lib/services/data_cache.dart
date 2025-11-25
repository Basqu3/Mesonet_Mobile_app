/// Simple in-memory cache for API responses
class DataCache {
  static final Map<String, CacheEntry> _cache = {};
  static const Duration cacheDuration = Duration(minutes: 5);

  /// Fetch data with caching. Returns cached data if available and not expired.
  static Future<String> fetchWithCache(
    String url,
    Future<String> Function(String) apiCall,
  ) async {
    final cached = _cache[url];

    // Return cached data if it exists and hasn't expired
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    // Fetch fresh data
    final freshData = await apiCall(url);
    _cache[url] = CacheEntry(freshData, DateTime.now());
    return freshData;
  }

  /// Clear all cached data
  static void clearCache() {
    _cache.clear();
  }

  /// Clear specific URL from cache
  static void clearUrl(String url) {
    _cache.remove(url);
  }

  /// Get cache size for debugging
  static int get cacheSize => _cache.length;
}

class CacheEntry {
  final String data;
  final DateTime timestamp;

  CacheEntry(this.data, this.timestamp);

  bool get isExpired {
    return DateTime.now().difference(timestamp) > DataCache.cacheDuration;
  }
}
