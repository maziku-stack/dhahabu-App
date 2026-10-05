import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final _api = ApiService();
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

  Future<Map<String, dynamic>> requestOtp(String phone, String role) =>
      _api.requestOtp(phone, role);

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
    _user = User.fromJson(data['user'] as Map<String, dynamic>);
    _authenticated = true;
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    await _api.setPin(pin);
    if (_user != null) {
      _user = User(
        id: _user!.id,
        phone: _user!.phone,
        fullName: _user!.fullName,
        role: _user!.role,
        phoneVerified: _user!.phoneVerified,
        pinSet: true,
        region: _user!.region,
        miningSite: _user!.miningSite,
        dealerVerified: _user!.dealerVerified,
        verificationStatus: _user!.verificationStatus,
      );
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    final data = await _api.getMe();
    _user = User.fromJson(data);
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _authenticated = false;
    notifyListeners();
  }
}
