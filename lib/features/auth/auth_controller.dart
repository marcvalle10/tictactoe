import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.signIn(email: email, password: password);
    } catch (_) {
      _errorMessage = 'No fue posible iniciar sesión.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.register(name: name, email: email, password: password);
    } catch (_) {
      _errorMessage = 'No fue posible crear la cuenta.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
