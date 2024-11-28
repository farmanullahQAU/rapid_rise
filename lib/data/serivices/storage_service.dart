import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  final GetStorage _storage = GetStorage();

  RxBool isDarkMode = true.obs;

  Future<StorageService> init() async {
    await GetStorage.init();

    return StorageService();
  }

  // Write generic data to cache as JSON
  Future<void> writeData<T>(String key, T data) async {
    if (data is Map<String, dynamic> || data is List) {
      await _storage.write(key, data); // Save raw data (Map or List)
    } else {
      throw Exception("Unsupported data type for caching");
    }
  }

  // Read generic data from cache
  Future<T?> readData<T>(String key) async {
    final cachedData = _storage.read(key);

    log("Cached Data:");
    if (cachedData == null) return null;

    // Return the cached data as is; you'll handle parsing externally
    return cachedData as T;
  }

  // Clear specific cache
  Future<void> clearCache(String key) async {
    await _storage.remove(key);
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    await _storage.erase();
  }
}
