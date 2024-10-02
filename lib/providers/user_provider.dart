import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lib_soma_front/controllers/user_controller.dart';
import 'package:lib_soma_front/models/user.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

final userProvider = ChangeNotifierProvider<UserNotifier>((ref) {
  final authNotifier =
      ref.watch(authProvider); // Escuchar el estado de autenticación
  return UserNotifier(authNotifier.token); // Pasar el token al UserNotifier
});

class UserNotifier extends ChangeNotifier {
  final UserController _userController = UserController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<UserModel> _users = [];
  UserModel? _selectedUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<UserModel> get users => _users;
  UserModel? get selectedUser => _selectedUser;

  String? _token;

  UserNotifier(this._token);

  // Mostrar SnackBar
  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Cargar el token almacenado al inicializar el UserNotifier
  Future<void> _loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
  }

  // Método para obtener todos los usuarios
  Future<void> fetchUsers(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        print('Iniciando fetchUsers con token: $_token');
        final users = await _userController.getAllUsers(
            1, 10, _token!); // Ejemplo de paginación
        _users = users;
        print('Usuarios obtenidos: ${_users.length}');
        _showSnackBar(context, 'Usuarios cargados correctamente');
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      print('Error al obtener los usuarios: $e');
      _showSnackBar(context, 'Error al obtener los usuarios: $e',
          isError: true);
    } finally {
      _isLoading = false;
      notifyListeners(); // Notificar cambios en la UI
    }
  }

  // Método para crear un usuario
  Future<void> createUser(UserModel user, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final newUser = await _userController.createUser(user, _token!);
        if (newUser != null) {
          _users.add(newUser);
          _showSnackBar(context, 'Usuario creado correctamente');
          notifyListeners(); // Notificar cambios en la lista de usuarios
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al crear el usuario: ${e.toString()}',
          isError: true);
    }
  }

  // Método para actualizar un usuario
  Future<void> updateUser(
      int userId, UserModel user, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final updatedUser =
            await _userController.updateUser(userId, user, _token!);
        if (updatedUser != null) {
          // Reemplazar el usuario actualizado en la lista de usuarios
          final index = _users.indexWhere((u) => u.username == user.username);
          if (index != -1) {
            _users[index] = updatedUser;
            _showSnackBar(context, 'Usuario actualizado correctamente');
            notifyListeners();
          }
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al actualizar el usuario: ${e.toString()}',
          isError: true);
    }
  }

  // Método para eliminar un usuario
  Future<void> deleteUser(int userId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        await _userController.deleteUser(userId, _token!);
        // Eliminar el usuario de la lista
        _users.removeWhere((user) => user.username == _selectedUser?.username);
        _showSnackBar(context, 'Usuario eliminado correctamente');
        notifyListeners();
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al eliminar el usuario: ${e.toString()}',
          isError: true);
    }
  }

  // Método para obtener un usuario específico
  Future<void> getUserById(int userId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final user = await _userController.getUserById(userId, _token!);
        _selectedUser = user;
        notifyListeners(); // Notificar que se seleccionó un nuevo usuario
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener el usuario: ${e.toString()}',
          isError: true);
    }
  }

  // Método para cambiar la contraseña de un usuario específico
  Future<void> updatePassword(
      int userId, String newPassword, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        await _userController.updatePassword(userId, newPassword, _token!);
        _showSnackBar(context, 'Contraseña actualizada correctamente');
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(
          context, 'Error al actualizar la contraseña: ${e.toString()}',
          isError: true);
    }
  }

  // Limpiar el usuario seleccionado
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }
}
