import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/goal_models.dart';
import '../services/user_service.dart';

class GoalService {
  final ApiService _apiService = ApiService();

  String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5182/api";
    }
    return "http://localhost:5182/api";
  }

  // Token'lı header oluştur
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _apiService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ---------------------------
  // GET GOALS
  // ---------------------------
  Future<List<Goal>> getGoals(int userId) async {
    try {
      final url = Uri.parse("$baseUrl/Goals/$userId");
      final headers = await _getAuthHeaders();

      print("Fetching goals for user: $userId");
      final response = await http.get(url, headers: headers);

      print("Get goals response status: ${response.statusCode}");
      print("Get goals response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Goal.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.");
      } else {
        throw Exception("Hedefler alınamadı: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error in getGoals: $e");
      rethrow;
    }
  }

  // ---------------------------
  // ADD GOAL (POST)
  // ---------------------------
  Future<bool> addGoal(CreateGoalModel model) async {
    try {
      final url = Uri.parse("$baseUrl/Goals");
      final headers = await _getAuthHeaders();
      final body = jsonEncode(model.toJson());

      print("Sending POST request to: $url");
      print("Headers: $headers");
      print("Body: $body");

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("Add goal response status: ${response.statusCode}");
      print("Add goal response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.");
      } else if (response.statusCode == 400) {
        // Parse validation errors if available
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            final errors = <String>[];
            errorData.forEach((key, value) {
              if (value is List) {
                errors.addAll(value.map((e) => e.toString()));
              } else {
                errors.add(value.toString());
              }
            });
            throw Exception("Doğrulama hatası: ${errors.join(', ')}");
          }
        } catch (e) {
          // If parsing fails, throw generic error
          throw Exception("Geçersiz veri: ${response.body}");
        }
        throw Exception("Geçersiz veri gönderildi.");
      } else {
        throw Exception("Hedef eklenemedi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error in addGoal: $e");
      rethrow;
    }
  }

  // ---------------------------
  // UPDATE GOAL (PUT)
  // ---------------------------
  Future<bool> updateGoal(int goalId, UpdateGoalModel model) async {
    try {
      final url = Uri.parse("$baseUrl/Goals/$goalId");
      final headers = await _getAuthHeaders();

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(model.toJson()),
      );

      print("Update goal response status: ${response.statusCode}");
      print("Update goal response body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.");
      } else if (response.statusCode == 404) {
        throw Exception("Hedef bulunamadı.");
      } else {
        throw Exception("Hedef güncellenemedi: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in updateGoal: $e");
      rethrow;
    }
  }

  // ---------------------------
  // DELETE GOAL
  // ---------------------------
  Future<bool> deleteGoal(int goalId) async {
    try {
      final url = Uri.parse("$baseUrl/Goals/$goalId");
      final headers = await _getAuthHeaders();

      final response = await http.delete(url, headers: headers);

      print("Delete goal response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.");
      } else if (response.statusCode == 404) {
        throw Exception("Hedef bulunamadı.");
      } else {
        throw Exception("Hedef silinemedi: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in deleteGoal: $e");
      rethrow;
    }
  }

  // ---------------------------
  // CONTRIBUTE TO GOAL
  // ---------------------------
  Future<bool> contributeToGoal(int goalId, ContributeToGoalModel model) async {
    try {
      final url = Uri.parse("$baseUrl/Goals/$goalId/contribute");
      final headers = await _getAuthHeaders();

      print("Contributing to goal: $goalId");
      print("Contribution data: ${model.toJson()}");

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(model.toJson()),
      );

      print("Contribute response status: ${response.statusCode}");
      print("Contribute response body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.");
      } else if (response.statusCode == 404) {
        throw Exception("Hedef veya hesap bulunamadı.");
      } else if (response.statusCode == 400) {
        // Try to parse the error message
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is String) {
            throw Exception(errorData);
          } else if (errorData is Map && errorData.containsKey('message')) {
            throw Exception(errorData['message']);
          } else {
            throw Exception(response.body);
          }
        } catch (e) {
          // If parsing fails, use the raw body
          throw Exception(response.body);
        }
      } else {
        throw Exception("Katkı eklenemedi: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in contributeToGoal: $e");
      rethrow;
    }
  }
}
