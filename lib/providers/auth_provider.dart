import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lib_soma_front/controllers/auth_controller.dart';

final authProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends ChangeNotifier {
  final AuthController _authController = AuthController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  String? _token;

  AuthNotifier() {
    _loadToken(); // Intenta cargar el token al inicializar
  }

  bool isAuthenticated() => _isAuthenticated;

  String? get token => _token; // Exponer el token para otros providers

  Future<void> _loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
    if (_token != null) {
      _isAuthenticated = true;
      notifyListeners(); // Notificar que ya está autenticado
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final token = await _authController.login(username, password);
      if (token != null) {
        _token = token;
        _isAuthenticated = true;
        // Guardar token de manera segura en almacenamiento cifrado
        await _secureStorage.write(key: 'auth_token', value: token);
        notifyListeners();
      } else {
        throw Exception('Credenciales incorrectas');
      }
    } catch (e) {
      throw Exception('Error de autenticación: ${e.toString()}');
    }
  }

  void logout() async {
    _isAuthenticated = false;
    _token = null;
    notifyListeners(); // Notificar que el usuario ha cerrado sesión

    // Eliminar el token de almacenamiento seguro
    await _secureStorage.delete(key: 'auth_token');
  }
}
