import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  final baseUrl = AppConstants.baseUrl;

  Future<String?> _token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(AppConstants.accessTokenKey);
  }

  Future<void> saveTokens(String a, String r) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConstants.accessTokenKey, a);
    await p.setString(AppConstants.refreshTokenKey, r);
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

  Future<Map<String, dynamic>> requestOtp(String phone, String role) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/otp/request/'),
      headers: await _headers(auth: false),
      body: jsonEncode({'phone': phone, 'role': role}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data as Map<String, dynamic>;
    throw Exception(data['detail'] ?? 'OTP failed');
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
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      return data;
    }
    throw Exception(data['detail'] ?? 'Verify failed');
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(Uri.parse('$baseUrl/auth/me/'),
        headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Not authenticated');
  }

  Future<void> setPin(String pin) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/pin/'),
      headers: await _headers(),
      body: jsonEncode({'pin': pin}),
    );
    if (res.statusCode != 200) throw Exception('PIN failed');
  }

  Future<void> logout() async => clearTokens();

  Future<List<dynamic>> getCurrentPrices() async {
    final res = await http.get(Uri.parse('$baseUrl/pricing/current/'),
        headers: await _headers());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body)['prices'] as List?) ?? [];
    }
    throw Exception('Prices failed');
  }

  Future<void> setPrice(
    String karat,
    double price,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/pricing/set/'),
      headers: await _headers(),
      body: jsonEncode({
        'karat': karat,
        'price_per_gram': price,
        'effective_at': DateTime.now().toUtc().toIso8601String(),
        'source': 'Admin App',
      }),
    );
    if (res.statusCode != 201) {
      throw Exception(jsonDecode(res.body)['detail'] ?? 'Set price failed');
    }
  }

  Future<List<dynamic>> getListings({bool mine = false, String? status}) async {
    var url = '$baseUrl/listings/?';
    if (mine) url += 'mine=1&';
    if (status != null) url += 'status=$status&';
    if (!mine) url += 'browse=1&';
    final res = await http.get(Uri.parse(url), headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['results'] as List? ?? []);
    }
    throw Exception('Listings failed');
  }

  Future<Map<String, dynamic>> createListing({
    required double weight,
    required String karat,
    required double askingPrice,
    double? pricePerGram,
    String notes = '',
    String region = '',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/listings/'),
      headers: await _headers(),
      body: jsonEncode({
        'weight_grams': weight,
        'karat': karat,
        'asking_price': askingPrice,
        'price_per_gram': pricePerGram,
        'notes': notes,
        'region': region,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201) return data as Map<String, dynamic>;
    throw Exception(data['detail'] ?? data.toString());
  }

  Future<Map<String, dynamic>> createTransaction({
    required String counterpartyPhone,
    required double weight,
    required String karat,
    required double pricePerGram,
    String notes = '',
    String? listingId,
  }) async {
    final body = {
      'counterparty_phone': counterpartyPhone,
      'weight_grams': weight,
      'karat': karat,
      'price_per_gram': pricePerGram,
      'notes': notes,
    };
    if (listingId != null) body['listing_id'] = listingId;
    final res = await http.post(
      Uri.parse('$baseUrl/transactions/create/'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      return data as Map<String, dynamic>;
    }
    throw Exception(data['detail'] ?? data.toString());
  }

  Future<Map<String, dynamic>> confirmTransaction(String id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/transactions/$id/confirm/'),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data as Map<String, dynamic>;
    throw Exception(data['detail'] ?? 'Confirm failed');
  }

  Future<List<dynamic>> getTransactions({String? status}) async {
    var url = '$baseUrl/transactions/';
    if (status != null) url += '?status=$status';
    final res = await http.get(Uri.parse(url), headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['results'] as List? ?? []);
    }
    throw Exception('Transactions failed');
  }

  Future<Map<String, dynamic>> getTaxSummary() async {
    final res = await http.get(Uri.parse('$baseUrl/transactions/tax-summary/'),
        headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Tax summary failed');
  }

  Future<Map<String, dynamic>> getAdminDashboard() async {
    final res = await http.get(
        Uri.parse('$baseUrl/transactions/admin/dashboard/'),
        headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Dashboard failed');
  }

  Future<List<dynamic>> getPendingDealers() async {
    final res = await http.get(
        Uri.parse('$baseUrl/auth/admin/dealers/pending/'),
        headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['results'] as List? ?? []);
    }
    throw Exception('Pending dealers failed');
  }

  Future<void> verifyDealer(String id,
      {bool approve = true, String reason = ''}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/admin/dealers/$id/verify/'),
      headers: await _headers(),
      body: jsonEncode(
          {'action': approve ? 'approve' : 'reject', 'reason': reason}),
    );
    if (res.statusCode != 200) throw Exception('Verify failed');
  }

  Future<List<dynamic>> getFeedback() async {
    final res = await http.get(Uri.parse('$baseUrl/feedback/'),
        headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['results'] as List? ?? []);
    }
    throw Exception('Feedback failed');
  }

  Future<void> submitFeedback(
      {required String type,
      required String subject,
      required String body}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/feedback/'),
      headers: await _headers(),
      body: jsonEncode({'type': type, 'subject': subject, 'body': body}),
    );
    if (res.statusCode != 201) throw Exception('Submit failed');
  }

  Future<List<dynamic>> getAuditLogs() async {
    final res = await http.get(Uri.parse('$baseUrl/transactions/admin/audit/'),
        headers: await _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List;
    throw Exception('Audit failed');
  }
}
