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
  int? _userId; // Almacenar el ID del usuario
  int? _roleId; // Almacenar el ID del rol

  AuthNotifier() {
    _loadCredentials(); // Cargar token, userId y roleId al inicializar
  }

  bool isAuthenticated() => _isAuthenticated;

  String? get token => _token; // Exponer el token para otros providers
  int? get userId => _userId; // Exponer el userId para otros providers
  int? get roleId => _roleId; // Exponer el roleId para otros providers

  Future<void> _loadCredentials() async {
    _token = await _secureStorage.read(key: 'auth_token');
    _userId = int.tryParse(await _secureStorage.read(key: 'user_id') ?? '');
    _roleId = int.tryParse(
        await _secureStorage.read(key: 'role_id') ?? ''); // Cargar role_id

    if (_token != null && _userId != null && _roleId != null) {
      _isAuthenticated = true;
      notifyListeners(); // Notificar que ya está autenticado
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final authData = await _authController.login(username, password);
      if (authData != null) {
        _token = authData['access_token'];
        _userId = authData['user_id'];
        _roleId = authData['role_id']; // Asignar role_id del Map de respuesta
        _isAuthenticated = true;

        // Guardar token, userId y roleId de manera segura en almacenamiento cifrado
        await _secureStorage.write(key: 'auth_token', value: _token);
        await _secureStorage.write(key: 'user_id', value: _userId.toString());
        await _secureStorage.write(key: 'role_id', value: _roleId.toString());

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
    _userId = null;
    _roleId = null;

    notifyListeners(); // Notificar que el usuario ha cerrado sesión

    // Eliminar el token, userId y roleId del almacenamiento seguro
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'user_id');
    await _secureStorage.delete(key: 'role_id');
  }
}
