import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhahabu/core/constants/app_constants.dart';

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  final baseUrl = AppConstants.baseUrl;
  static const _requestTimeout = Duration(seconds: 12);
  static const _secureStorage = FlutterSecureStorage();

  Future<bool> hasAccessToken() async => (await _token())?.isNotEmpty == true;

  Future<http.Response> _get(Uri uri, {required Map<String, String> headers}) =>
      http.get(uri, headers: headers).timeout(_requestTimeout);

  Future<http.Response> _post(
    Uri uri, {
    required Map<String, String> headers,
    String? body,
  }) =>
      http.post(uri, headers: headers, body: body).timeout(_requestTimeout);

  Future<http.Response> _patch(
    Uri uri, {
    required Map<String, String> headers,
    String? body,
  }) =>
      http.patch(uri, headers: headers, body: body).timeout(_requestTimeout);

  Future<String?> _token() async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token != null) return token;
    await _migrateLegacyTokens();
    return _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> _migrateLegacyTokens() async {
    final p = await SharedPreferences.getInstance();
    final access = p.getString(AppConstants.accessTokenKey);
    final refresh = p.getString(AppConstants.refreshTokenKey);
    if (access != null) {
      await _secureStorage.write(
          key: AppConstants.accessTokenKey, value: access);
    }
    if (refresh != null) {
      await _secureStorage.write(
          key: AppConstants.refreshTokenKey, value: refresh);
    }
    await p.remove(AppConstants.accessTokenKey);
    await p.remove(AppConstants.refreshTokenKey);
  }

  Future<void> saveTokens(String a, String r) async {
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: a);
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: r);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    final p = await SharedPreferences.getInstance();
    await p.remove(AppConstants.accessTokenKey);
    await p.remove(AppConstants.refreshTokenKey);
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final t = await _token();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  Map<String, dynamic> _decodeApiResponse(http.Response response) {
    final body = response.body.trim();
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Expected a JSON object');
    } on FormatException {
      final isHtml = body.toLowerCase().startsWith('<!doctype html') ||
          body.toLowerCase().startsWith('<html');
      final hint = isHtml
          ? 'The server returned an HTML page. Check API_BASE_URL and confirm the backend is running.'
          : 'The server returned a non-JSON response.';
      throw Exception('$hint (HTTP ${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> requestOtp(
    String phone,
    String role, {
    bool allowRegistration = true,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/auth/otp/request/'),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'phone': phone,
        'role': role,
        'allow_registration': allowRegistration,
      }),
    );
    final data = _decodeApiResponse(res);
    if (res.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'OTP failed');
  }

  Future<Map<String, dynamic>> registerWithEmailPassword({
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required String password,
    required String passwordConfirmation,
    required bool privacyNoticeAcknowledged,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'privacy_notice_version': '2026-10-draft-1',
        'privacy_notice_acknowledged': privacyNoticeAcknowledged,
      }),
    );
    final data = _decodeApiResponse(res);
    if (res.statusCode == 201) {
      await saveTokens(data['access'], data['refresh']);
      return data;
    }
    final detail = data['detail'] ?? data.values.first;
    throw Exception(detail is List ? detail.join(' ') : detail.toString());
  }

  Future<Map<String, dynamic>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: await _headers(auth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _decodeApiResponse(res);
    if (res.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      return data;
    }
    final detail = data['detail'] ?? data.values.first;
    throw Exception(detail is List ? detail.join(' ') : detail.toString());
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
    required String role,
    String fullName = '',
    String region = '',
    String miningSite = '',
    String businessName = '',
    String licenseNumber = '',
  }) async {
    final res = await _post(
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
        'license_number': licenseNumber,
        'privacy_notice_version': '2026-10-draft-1',
      }),
    );
    final data = _decodeApiResponse(res);
    if (res.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      return data;
    }
    throw Exception(data['detail'] ?? 'Verify failed');
  }

  Future<Map<String, dynamic>> getMe() async {
    final res =
        await _get(Uri.parse('$baseUrl/auth/me/'), headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Not authenticated');
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    required String region,
    required String miningSite,
  }) async {
    final res = await _patch(
      Uri.parse('$baseUrl/auth/me/'),
      headers: await _headers(),
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'region': region,
        'mining_site': miningSite,
      }),
    );
    final data = _decodeApiResponse(res);
    if (res.statusCode == 200) {
      return data;
    }
    final detail = data['detail'] ?? data.values.first;
    throw Exception(detail is List ? detail.join(' ') : detail.toString());
  }

  Future<void> setPin(String pin) async {
    final res = await _post(
      Uri.parse('$baseUrl/auth/pin/'),
      headers: await _headers(),
      body: jsonEncode({'pin': pin}),
    );
    if (res.statusCode != 200) throw Exception('PIN failed');
  }

  Future<void> logout() async => clearTokens();

  Future<Map<String, dynamic>> exportMyData() async {
    final res = await _get(Uri.parse('$baseUrl/auth/privacy/export/'),
        headers: await _headers());
    final data = _decodeApiResponse(res);
    if (res.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Could not export your data');
  }

  Future<void> submitPrivacyRequest(
      {required String type, String details = ''}) async {
    final res = await _post(Uri.parse('$baseUrl/auth/privacy/requests/'),
        headers: await _headers(),
        body: jsonEncode({'request_type': type, 'details': details}));
    final data = _decodeApiResponse(res);
    if (res.statusCode != 201) {
      throw Exception(data['detail'] ?? 'Could not submit request');
    }
  }

  Future<List<dynamic>> getCurrentPrices() async {
    final res = await _get(Uri.parse('$baseUrl/pricing/current/'),
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
    final res = await _post(
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
    final res = await _get(Uri.parse(url), headers: await _headers());
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
    bool sharePhone = false,
  }) async {
    final res = await _post(
      Uri.parse('$baseUrl/listings/'),
      headers: await _headers(),
      body: jsonEncode({
        'weight_grams': weight,
        'karat': karat,
        'asking_price': askingPrice,
        'price_per_gram': pricePerGram,
        'notes': notes,
        'region': region,
        'share_phone': sharePhone,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201) return data as Map<String, dynamic>;
    throw Exception(data['detail'] ?? data.toString());
  }

  Future<void> setListingPhoneSharing(String id, bool share) async {
    final response = await http
        .patch(
          Uri.parse('$baseUrl/listings/$id/'),
          headers: await _headers(),
          body: jsonEncode({'share_phone': share}),
        )
        .timeout(_requestTimeout);
    if (response.statusCode != 200) {
      final data = _decodeApiResponse(response);
      throw Exception(data['detail'] ?? 'Could not update listing privacy');
    }
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
    final res = await _post(
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

  Future<Map<String, dynamic>> confirmTransaction(String id,
      {required String pin}) async {
    final res = await _post(
      Uri.parse('$baseUrl/transactions/$id/confirm/'),
      headers: await _headers(),
      body: jsonEncode({'pin': pin}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data as Map<String, dynamic>;
    throw Exception(data['detail'] ?? 'Confirm failed');
  }

  Future<List<dynamic>> getTransactions({String? status}) async {
    var url = '$baseUrl/transactions/';
    if (status != null) url += '?status=$status';
    final res = await _get(Uri.parse(url), headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['results'] as List? ?? []);
    }
    throw Exception('Transactions failed');
  }

  Future<Map<String, dynamic>> getTaxSummary() async {
    final res = await _get(Uri.parse('$baseUrl/transactions/tax-summary/'),
        headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Tax summary failed');
  }

  Future<Map<String, dynamic>> getAdminDashboard() async {
    final res = await _get(Uri.parse('$baseUrl/transactions/admin/dashboard/'),
        headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Dashboard failed');
  }

  Future<List<dynamic>> getPendingDealers() async {
    final res = await _get(Uri.parse('$baseUrl/auth/admin/dealers/pending/'),
        headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['results'] as List? ?? []);
    }
    throw Exception('Pending dealers failed');
  }

  Future<void> verifyDealer(String id,
      {bool approve = true, String reason = ''}) async {
    final res = await _post(
      Uri.parse('$baseUrl/auth/admin/dealers/$id/verify/'),
      headers: await _headers(),
      body: jsonEncode(
          {'action': approve ? 'approve' : 'reject', 'reason': reason}),
    );
    if (res.statusCode != 200) throw Exception('Verify failed');
  }

  Future<List<dynamic>> getFeedback() async {
    final res =
        await _get(Uri.parse('$baseUrl/feedback/'), headers: await _headers());
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
    final res = await _post(
      Uri.parse('$baseUrl/feedback/'),
      headers: await _headers(),
      body: jsonEncode({'type': type, 'subject': subject, 'body': body}),
    );
    if (res.statusCode != 201) throw Exception('Submit failed');
  }

  Future<void> respondToFeedback(String id, String response,
      {String status = 'resolved'}) async {
    final res = await _post(
      Uri.parse('$baseUrl/feedback/$id/respond/'),
      headers: await _headers(),
      body: jsonEncode({'response': response, 'status': status}),
    );
    if (res.statusCode != 200) {
      final data = _decodeApiResponse(res);
      throw Exception(data['detail'] ?? 'Could not update feedback');
    }
  }

  Future<List<dynamic>> getAuditLogs() async {
    final res = await _get(Uri.parse('$baseUrl/transactions/admin/audit/'),
        headers: await _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List;
    throw Exception('Audit failed');
  }
}
