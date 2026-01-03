import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // kIsWeb için

class ApiService {
  final _storage = const FlutterSecureStorage();

  // Platform'a göre base URL (Web desteği ile)
  String get baseUrl {
    // Web için
    if (kIsWeb) {
      return "http://localhost:5182/api";
    }
    
    // Mobil için (Android/iOS)
    // Android emulator: 10.0.2.2
    // iOS simulator: localhost
    // Fiziksel cihaz: bilgisayarınızın IP adresi
    return "http://localhost:5182/api";
  }

  // Token kaydet
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Token oku
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Token sil
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_name');
  }

  // userId oku
  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  // userName oku
  Future<String?> getUserName() async {
    return await _storage.read(key: 'user_name');
  }

  // Register User
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/Auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Kayıt başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kayıt sırasında hata oluştu: $e');
    }
  }

  // Login User
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/Auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);
          await _storage.write(key: 'user_id', value: responseData['userId'].toString());
          await _storage.write(key: 'user_name', value: responseData['username'] ?? 'Kullanıcı');
        }
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Giriş başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Giriş sırasında hata oluştu: $e');
    }
  }

  // GET request (token ile)
  Future<List<dynamic>> getAccounts() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token bulunamadı. Lütfen giriş yapın.');
    }

    final url = Uri.parse('$baseUrl/Accounts');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
    } else {
      throw Exception('Hata: ${response.statusCode}');
    }
  }

  // POST request (token ile)
  Future<Map<String, dynamic>> createAccount({
    required String name,
    required double balance,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token bulunamadı. Lütfen giriş yapın.');
    }

    final url = Uri.parse('$baseUrl/Accounts');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'balance': balance}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
    } else {
      throw Exception('Hata: ${response.statusCode}');
    }
  }
}