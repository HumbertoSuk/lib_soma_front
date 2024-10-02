import 'package:dio/dio.dart';
import 'package:lib_soma_front/config/domain/domain.dart'; // Reemplaza con la URL base correcta de tu dominio
import 'package:lib_soma_front/models/user.dart';
import 'package:logger/logger.dart';

class UserController {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  UserController() {
    _dio.options.baseUrl = baseUrl;

    // Interceptor para registrar solicitudes y respuestas
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.i('Solicitud: ${options.method} ${options.path}');
        _logger.d('Datos enviados: ${options.data}');
        return handler.next(options); // Continuar con la solicitud
      },
      onResponse: (response, handler) {
        _logger.i(
            'Respuesta recibida: ${response.statusCode} ${response.statusMessage}');
        _logger.d('Datos recibidos: ${response.data}');
        return handler.next(response); // Continuar con la respuesta
      },
      onError: (DioException error, handler) {
        _logger.e('Error en la solicitud: ${error.message}');
        if (error.response != null) {
          _logger.e('Datos de error: ${error.response?.data}');
        }
        return handler.next(error); // Continuar con el error
      },
    ));
  }

  Future<UserModel?> createUser(UserModel user, String token) async {
    try {
      final response = await _dio.post(
        '/register/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: user.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i('Usuario creado exitosamente');
        return UserModel.fromJson(response.data);
      } else {
        _logger.w('Error al crear usuario: ${response.data}');
        throw Exception('Error al crear el usuario');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en createUser: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  Future<UserModel?> getUserById(int userId, String token) async {
    try {
      final response = await _dio.get(
        '/users/$userId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Verifica si la respuesta es un mapa (objeto único)
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        _logger.i('Usuario obtenido exitosamente');
        return UserModel.fromJson(response.data);
      } else {
        _logger.w('Error al obtener usuario: ${response.data}');
        throw Exception('Error al obtener el usuario');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getUserById: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Actualiza un usuario
  Future<UserModel?> updateUser(
      int userId, UserModel user, String token) async {
    try {
      final response = await _dio.put(
        '/users/$userId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: user.toJson(),
      );

      if (response.statusCode == 200) {
        _logger.i('Usuario actualizado exitosamente');
        return UserModel.fromJson(response.data);
      } else {
        _logger.w('Error al actualizar usuario: ${response.data}');
        throw Exception('Error al actualizar el usuario');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en updateUser: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Elimina un usuario por ID
  Future<void> deleteUser(int userId, String token) async {
    try {
      final response = await _dio.delete(
        '/users/$userId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Usuario eliminado exitosamente');
      } else {
        _logger.w('Error al eliminar usuario: ${response.data}');
        throw Exception('Error al eliminar el usuario');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en deleteUser: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtiene todos los usuarios con paginación
  Future<List<UserModel>> getAllUsers(
      int page, int perPage, String token) async {
    try {
      final response = await _dio.get(
        '/users/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        _logger.i('Usuarios obtenidos exitosamente');
        List<dynamic> usersData = response.data as List<dynamic>;
        return usersData.map((json) => UserModel.fromJson(json)).toList();
      } else {
        _logger.w('Error al obtener usuarios: ${response.data}');
        throw Exception('Error al obtener los usuarios');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getAllUsers: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Método para cambiar la contraseña de un usuario
  Future<void> updatePassword(
      int userId, String newPassword, String token) async {
    try {
      final response = await _dio.put(
        '/users/$userId/update-password/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json', // Indicamos que es JSON
          },
        ),
        data: {
          'new_password':
              newPassword, // Enviamos la nueva contraseña en el cuerpo
        },
      );

      if (response.statusCode == 200) {
        _logger.i('Contraseña actualizada exitosamente');
      } else {
        _logger.w('Error al actualizar la contraseña: ${response.data}');
        throw Exception('Error al actualizar la contraseña');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en updatePassword: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
