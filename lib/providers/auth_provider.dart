import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  static const _demoEmail = 'admin@smartboard.app';
  static const _demoPassword = 'password123';

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signIn({required String email, required String password}) async {
    _setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (email.trim().toLowerCase() == _demoEmail && password == _demoPassword) {
      _isAuthenticated = true;
      _errorMessage = null;
    } else {
      _errorMessage =
          'Invalid email or password. Use $_demoEmail / $_demoPassword to continue.';
      _isAuthenticated = false;
      _setLoading(false);
      throw Exception(_errorMessage);
    }

    _setLoading(false);
  }

  void signOut() {
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
