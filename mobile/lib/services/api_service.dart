import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = AppConstants.baseUrl;

  Future<String?> _token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(AppConstants.accessTokenKey);
  }

  Future<void> saveTokens(String access, String refresh) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConstants.accessTokenKey, access);
    await p.setString(AppConstants.refreshTokenKey, refresh);
  }

  Future<void> clearTokens() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(AppConstants.accessTokenKey);
    await p.remove(AppConstants.refreshTokenKey);
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final t = await _token();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  // ---- Auth ----
  Future<Map<String, dynamic>> requestOtp(String phone, String role) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/otp/request/'),
      headers: await _headers(auth: false),
      body: jsonEncode({'phone': phone, 'role': role}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'OTP request failed');
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
    required String role,
    String fullName = '',
    String region = '',
    String miningSite = '',
    String businessName = '',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/otp/verify/'),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'phone': phone,
        'code': code,
        'role': role,
        'full_name': fullName,
        'region': region,
        'mining_site': miningSite,
        'business_name': businessName,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      return data;
    }
    throw Exception(data['detail'] ?? 'OTP verification failed');
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(Uri.parse('$baseUrl/auth/me/'), headers: await _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Not authenticated');
  }

  Future<void> logout() async => clearTokens();

  // ---- Pricing ----
  Future<List<dynamic>> getCurrentPrices() async {
    final res = await http.get(Uri.parse('$baseUrl/pricing/current/'), headers: await _headers());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body)['prices'] as List?) ?? [];
    }
    throw Exception('Failed to load prices');
  }

  Future<void> setPrice({
    required String karat,
    required double pricePerGram,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/pricing/set/'),
      headers: await _headers(),
      body: jsonEncode({
        'karat': karat,
        'price_per_gram': pricePerGram,
        'effective_at': DateTime.now().toUtc().toIso8601String(),
        'source': 'Admin App',
      }),
    );
    if (res.statusCode != 201) {
      throw Exception(jsonDecode(res.body)['detail'] ?? 'Failed to set price');
    }
  }

  // ---- Transactions ----
  Future<Map<String, dynamic>> createTransaction({
    required String counterpartyPhone,
    required double weightGrams,
    required String karat,
    required double pricePerGram,
    String notes = '',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/transactions/create/'),
      headers: await _headers(),
      body: jsonEncode({
        'counterparty_phone': counterpartyPhone,
        'weight_grams': weightGrams,
        'karat': karat,
        'price_per_gram': pricePerGram,
        'notes': notes,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) return data;
    throw Exception(data['detail'] ?? data.toString());
  }

  Future<Map<String, dynamic>> confirmTransaction(String txnId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/transactions/$txnId/confirm/'),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Confirm failed');
  }

  Future<List<dynamic>> getMyTransactions({String? status}) async {
    var url = '$baseUrl/transactions/';
    if (status != null) url += '?status=$status';
    final res = await http.get(Uri.parse(url), headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['results'] as List? ?? []);
    }
    throw Exception('Failed to load transactions');
  }

  Future<Map<String, dynamic>> getAdminDashboard() async {
    final res = await http.get(
      Uri.parse('$baseUrl/transactions/admin/dashboard/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load dashboard');
  }

  // ---- Feedback ----
  Future<List<dynamic>> getFeedback() async {
    final res = await http.get(Uri.parse('$baseUrl/feedback/'), headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['results'] as List? ?? []);
    }
    throw Exception('Failed to load feedback');
  }

  Future<void> submitFeedback({
    required String type,
    required String subject,
    required String body,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/feedback/'),
      headers: await _headers(),
      body: jsonEncode({'type': type, 'subject': subject, 'body': body}),
    );
    if (res.statusCode != 201) {
      throw Exception(jsonDecode(res.body)['detail'] ?? 'Submit failed');
    }
  }
}
