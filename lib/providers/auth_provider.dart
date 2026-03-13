import 'package:flutter/material.dart';
import 'package:project_management_app/repositories/auth_repository.dart';

class ProjectAuthProvider extends ChangeNotifier {
  final _repository = AuthRepository();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loginAccount(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.loginAccount(email, password);
    } catch (e) {
      throw Exception('Error failed login: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String userName,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.createUserWithEmailAndPassword(
        email,
        password,
        userName,
      );
    } catch (e) {
      throw Exception('Failed to create account: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
  }
}
