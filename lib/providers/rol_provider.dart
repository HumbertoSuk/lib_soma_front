import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lib_soma_front/controllers/rol_controller.dart';
import 'package:lib_soma_front/models/rol.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

final roleProvider = ChangeNotifierProvider<RoleNotifier>((ref) {
  final authNotifier =
      ref.watch(authProvider); // Escuchar el estado de autenticación
  return RoleNotifier(authNotifier.token); // Pasar el token al RoleNotifier
});

class RoleNotifier extends ChangeNotifier {
  final RoleController _roleController = RoleController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<Role> _roles = [];
  Role? _selectedRole;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Role> get roles => _roles;
  Role? get selectedRole => _selectedRole;

  String? _token;

  RoleNotifier(this._token);

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

  // Cargar el token almacenado al inicializar el RoleNotifier
  Future<void> _loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
  }

  // Método para obtener todos los roles
  Future<void> fetchRoles(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token == null)
        await _loadToken(); // Cargar token si no está disponible

      if (_token != null) {
        final roles = await _roleController.getAllRoles(
            1, 10, _token!); // Ejemplo de paginación
        _roles = roles;
        _showSnackBar(context, 'Roles cargados correctamente');
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener los roles: ${e.toString()}',
          isError: true);
    } finally {
      _isLoading = false;
      notifyListeners(); // Notificar cambios en la UI
    }
  }

  // Método para crear un rol
  Future<void> createRole(String name, BuildContext context) async {
    try {
      if (_token == null)
        await _loadToken(); // Cargar token si no está disponible

      if (_token != null) {
        final newRole = await _roleController.createRole(name, _token!);
        if (newRole != null) {
          _roles.add(newRole);
          _showSnackBar(context, 'Rol creado correctamente');
          notifyListeners(); // Notificar cambios en la lista de roles
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al crear el rol: ${e.toString()}',
          isError: true);
    }
  }

  // Método para actualizar un rol
  Future<void> updateRole(int roleId, String name, BuildContext context) async {
    try {
      if (_token == null)
        await _loadToken(); // Cargar token si no está disponible

      if (_token != null) {
        final updatedRole =
            await _roleController.updateRole(roleId, name, _token!);
        if (updatedRole != null) {
          // Reemplazar el rol actualizado en la lista de roles
          final index = _roles.indexWhere((role) => role.id == roleId);
          if (index != -1) {
            _roles[index] = updatedRole;
            _showSnackBar(context, 'Rol actualizado correctamente');
            notifyListeners();
          }
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al actualizar el rol: ${e.toString()}',
          isError: true);
    }
  }

  // Método para eliminar un rol
  Future<void> deleteRole(int roleId, BuildContext context) async {
    try {
      if (_token == null)
        await _loadToken(); // Cargar token si no está disponible

      if (_token != null) {
        await _roleController.deleteRole(roleId, _token!);
        // Eliminar el rol de la lista
        _roles.removeWhere((role) => role.id == roleId);
        _showSnackBar(context, 'Rol eliminado correctamente');
        notifyListeners();
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al eliminar el rol: ${e.toString()}',
          isError: true);
    }
  }

  // Método para obtener un rol específico
  Future<void> getRoleById(int roleId, BuildContext context) async {
    try {
      if (_token == null)
        await _loadToken(); // Cargar token si no está disponible

      if (_token != null) {
        final role = await _roleController.getRoleById(roleId, _token!);
        _selectedRole = role;
        notifyListeners(); // Notificar que se seleccionó un nuevo rol
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener el rol: ${e.toString()}',
          isError: true);
    }
  }

  // Limpiar el rol seleccionado
  void clearSelectedRole() {
    _selectedRole = null;
    notifyListeners();
  }
}
