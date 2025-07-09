import 'package:get_storage/get_storage.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  late GetStorage _storage;

  // Initialize storage
  Future<void> init() async {
    await GetStorage.init();
    _storage = GetStorage();
  }

  // Generic methods for storage operations
  T? read<T>(String key) {
    try {
      return _storage.read<T>(key);
    } catch (e) {
      return null;
    }
  }

  Future<void> write(String key, dynamic value) async {
    try {
      await _storage.write(key, value);
    } catch (e) {
      throw Exception('فشل في كتابة البيانات: ${e.toString()}');
    }
  }

  Future<void> remove(String key) async {
    try {
      await _storage.remove(key);
    } catch (e) {
      throw Exception('فشل في حذف البيانات: ${e.toString()}');
    }
  }

  Future<void> clear() async {
    try {
      await _storage.erase();
    } catch (e) {
      throw Exception('فشل في مسح جميع البيانات: ${e.toString()}');
    }
  }

  bool hasData(String key) {
    try {
      return _storage.hasData(key);
    } catch (e) {
      return false;
    }
  }

  // Specific methods for app data
  Future<void> saveUserSession(Map<String, dynamic> userData) async {
    await write('user_session', userData);
  }

  Map<String, dynamic>? getUserSession() {
    return read<Map<String, dynamic>>('user_session');
  }

  Future<void> clearUserSession() async {
    await remove('user_session');
  }

  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await write('app_settings', settings);
  }

  Map<String, dynamic>? getAppSettings() {
    return read<Map<String, dynamic>>('app_settings');
  }
}