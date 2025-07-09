import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../models/user.dart';

class AuthService {
  final GetStorage _storage = GetStorage();
  static const String baseUrl = AppConfig.baseUrl;

  // Login method - ربط مع الباك إند
  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print(response.body);


      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);

        final user = User.fromJson(responseData['user']);

        // حفظ التوكن إذا كان متوفراً
        if (responseData['access_token'] != null) {
          await _storage.write('auth_token', responseData['access_token']);
        }

        return user;
      } else if (response.statusCode == 401) {
        throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      } else if (response.statusCode == 403) {
        throw Exception('غير مسموح: يمكن للسائقين فقط تسجيل الدخول');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'حدث خطأ في الخادم');
      }
    } catch (e) {
      print(e);
      if (e.toString().contains('غير مسموح') || e.toString().contains('البريد الإلكتروني')) {
        rethrow;
      }
      throw Exception('فشل في الاتصال بالخادم: ${e.toString()}');
    }
  }

  // Register method (للمستقبل إذا احتجت)
  Future<User?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role': 'DRIVER', // تسجيل كسائق فقط
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final user = User.fromJson(responseData['user']);

        // حفظ التوكن
        if (responseData['access_token'] != null) {
          await _storage.write('auth_token', responseData['access_token']);
        }

        return user;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في التسجيل');
      }
    } catch (e) {
      throw Exception('فشل في التسجيل: ${e.toString()}');
    }
  }

  // Get current user from storage
  User? getCurrentUser() {
    try {
      final userData = _storage.read('user');
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Save user to storage
  Future<void> saveUser(User user) async {
    try {
      await _storage.write('user', user.toJson());
    } catch (e) {
      throw Exception('فشل في حفظ بيانات المستخدم');
    }
  }

  // Get auth token
  String? getAuthToken() {
    try {
      return _storage.read('auth_token');
    } catch (e) {
      return null;
    }
  }

  // Clear user data and token
  Future<void> clearUserData() async {
    try {
      await _storage.remove('user');
      await _storage.remove('auth_token');
    } catch (e) {
      throw Exception('فشل في مسح بيانات المستخدم');
    }
  }

  // Logout method - اختياري إذا كان لديك endpoint للخروج
  Future<void> logout() async {
    try {
      final token = getAuthToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // تجاهل أخطاء تسجيل الخروج
    } finally {
      await clearUserData();
    }
  }

  // Verify token (للتحقق من صلاحية التوكن)
  Future<bool> verifyToken() async {
    try {
      final token = getAuthToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}