import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _loading = true;
  bool _authenticated = false;

  User? get user => _user;
  bool get isLoading => _loading;
  bool get isAuthenticated => _authenticated;

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    try {
      final data = await _api.getMe();
      _user = User.fromJson(data);
      _authenticated = true;
    } catch (_) {
      _user = null;
      _authenticated = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> requestOtp(String phone, String role) {
    return _api.requestOtp(phone, role);
  }

  Future<void> verifyOtp({
    required String phone,
    required String code,
    required String role,
    String fullName = '',
    String region = '',
    String miningSite = '',
    String businessName = '',
  }) async {
    final data = await _api.verifyOtp(
      phone: phone,
      code: code,
      role: role,
      fullName: fullName,
      region: region,
      miningSite: miningSite,
      businessName: businessName,
    );
    _user = User.fromJson(data['user']);
    _authenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _authenticated = false;
    notifyListeners();
  }
}
