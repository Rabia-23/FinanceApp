import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // kIsWeb için
import '../models/home_models.dart';
import 'user_service.dart'; // Token almak için

class HomeService {
  final ApiService _apiService = ApiService();

  // Platform'a gore base URL (Web destegi ile)
  String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5182/api";
    }
    return "http://localhost:5182/api";
  }

  // Token'li header olusturma
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _apiService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ---------------------------
  // GET HOME DATA
  // ---------------------------
  Future<HomeData> getHomeData(String jwtToken) async {
    final url = Uri.parse("$baseUrl/Home/me");

    final response = await http.get(url, headers: {
      "Authorization": "Bearer $jwtToken",
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body); // json'i dart map'e cevir
      return HomeData.fromJson(jsonMap); // model o mapten HomeData objesi olusturur
    } else if (response.statusCode == 401) {
      throw Exception("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.");
    } else {
      throw Exception("Home verisi alınamadı: ${response.statusCode}");
    }
  }

  // ---------------------------
  // GET TRANSACTIONS
  // ---------------------------
  Future<List<Transaction>> getTransactions(int userId) async {
    final url = Uri.parse("$baseUrl/Transactions/$userId");
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Transaction.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.");
    } else {
      throw Exception("İşlemler alınamadı: ${response.statusCode}");
    }
  }

  // ---------------------------
  // ADD TRANSACTION (POST)
  // ---------------------------
  Future<bool> addTransaction(CreateTransactionModel model) async {
    final url = Uri.parse("$baseUrl/Transactions");
    final headers = await _getAuthHeaders();

    final jsonBody = jsonEncode(model.toJson());

    final response = await http.post(
      url,
      headers: headers,
      body: jsonBody,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception("İşlem eklenemedi: ${response.body}");
    }
  }

  // ---------------------------
  // UPDATE TRANSACTION (PUT)
  // ---------------------------
  Future<bool> updateTransaction(UpdateTransactionModel model) async {
    final url = Uri.parse("$baseUrl/Transactions/${model.transactionId}");
    final headers = await _getAuthHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("İşlem güncellenemedi: ${response.body}");
    }
  }

  // ---------------------------
  // DELETE TRANSACTION
  // ---------------------------
  Future<bool> deleteTransaction(int transactionId) async {
    final url = Uri.parse("$baseUrl/Transactions/$transactionId");
    final headers = await _getAuthHeaders();

    final response = await http.delete(url, headers: headers);

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // ---------------------------
  // GET ACCOUNTS
  // ---------------------------
  Future<List<Account>> getAccounts(int userId) async {
    final url = Uri.parse("$baseUrl/Accounts/$userId");
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Account.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.");
    } else {
      throw Exception("Hesaplar alınamadı: ${response.statusCode}");
    }
  }

  // ---------------------------
  // ADD ACCOUNT (POST)
  // ---------------------------
  Future<bool> addAccount(CreateAccountModel model) async {
    final url = Uri.parse("$baseUrl/Accounts");
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(model.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ---------------------------
  // DELETE ACCOUNT
  // ---------------------------
  Future<bool> deleteAccount(int accountId) async {
    final url = Uri.parse("$baseUrl/Accounts/$accountId");
    final headers = await _getAuthHeaders();

    final response = await http.delete(url, headers: headers);

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // ---------------------------
  // GET BUDGETS
  // ---------------------------
  Future<List<Budget>> getBudgets(int userId) async {
    final url = Uri.parse("$baseUrl/Budgets/$userId");
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Budget.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.");
    } else {
      throw Exception("Bütçeler alınamadı: ${response.statusCode}");
    }
  }

  // ---------------------------
  // ADD BUDGET (POST)
  // ---------------------------
  Future<bool> addBudget(CreateBudgetModel model) async {
    final url = Uri.parse("$baseUrl/Budgets");
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(model.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ---------------------------
  // UPDATE BUDGET (PUT)
  // ---------------------------
  Future<bool> updateBudget(int budgetId, UpdateBudgetModel model) async {
    final url = Uri.parse("$baseUrl/Budgets/$budgetId");
    final headers = await _getAuthHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(model.toJson()),
    );

    return response.statusCode == 200;
  }

  // ---------------------------
  // DELETE BUDGET
  // ---------------------------
  Future<bool> deleteBudget(int budgetId) async {
    final url = Uri.parse("$baseUrl/Budgets/$budgetId");
    final headers = await _getAuthHeaders();

    final response = await http.delete(url, headers: headers);

    return response.statusCode == 200 || response.statusCode == 204;
  }
}