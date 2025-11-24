import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/subscription_models.dart';
import '../services/user_service.dart';

class SubscriptionService {
  final ApiService _apiService = ApiService();

  String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5182/api";
    }
    return "http://localhost:5182/api";
  }

  // ✅ Token'lı header oluştur
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _apiService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ---------------------------
  // GET SUBSCRIPTIONS
  // ---------------------------
  Future<List<Subscription>> getSubscriptions(int userId) async {
    final url = Uri.parse("$baseUrl/Subscriptions/$userId");
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Subscription.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.");
    } else {
      throw Exception("Abonelikler alınamadı: ${response.statusCode}");
    }
  }

  // ---------------------------
  // ADD SUBSCRIPTION (POST)
  // ---------------------------
  Future<bool> addSubscription(CreateSubscriptionModel model) async {
    final url = Uri.parse("$baseUrl/Subscriptions");
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(model.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ---------------------------
  // UPDATE SUBSCRIPTION (PUT)
  // ---------------------------
  Future<bool> updateSubscription(int subscriptionId, UpdateSubscriptionModel model) async {
    final url = Uri.parse("$baseUrl/Subscriptions/$subscriptionId");
    final headers = await _getAuthHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(model.toJson()),
    );

    return response.statusCode == 200;
  }

  // ---------------------------
  // DELETE SUBSCRIPTION
  // ---------------------------
  Future<bool> deleteSubscription(int subscriptionId) async {
    final url = Uri.parse("$baseUrl/Subscriptions/$subscriptionId");
    final headers = await _getAuthHeaders();

    final response = await http.delete(url, headers: headers);

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // ---------------------------
  // PAY SUBSCRIPTION
  // ---------------------------
  Future<bool> paySubscription(int subscriptionId, PaySubscriptionModel model) async {
    final url = Uri.parse("$baseUrl/Subscriptions/$subscriptionId/pay");
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(model.toJson()),
    );

    return response.statusCode == 200;
  }

  // ---------------------------
  // SKIP SUBSCRIPTION
  // ---------------------------
  Future<bool> skipSubscription(int subscriptionId) async {
    final url = Uri.parse("$baseUrl/Subscriptions/$subscriptionId/skip");
    final headers = await _getAuthHeaders();

    final response = await http.post(url, headers: headers);

    return response.statusCode == 200;
  }
}