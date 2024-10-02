import 'package:dio/dio.dart';
import 'package:lib_soma_front/config/domain/domain.dart'; // Reemplaza con la URL base correcta de tu dominio
import 'package:lib_soma_front/models/rol.dart';
import 'package:logger/logger.dart';

class RoleController {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  RoleController() {
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

  // Crea un nuevo rol
  Future<Role?> createRole(String name, String token) async {
    try {
      final response = await _dio.post(
        '/roles/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'name': name,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i('Rol creado exitosamente');
        return Role.fromJson(response.data);
      } else {
        _logger.w('Error al crear rol: ${response.data}');
        throw Exception('Error al crear el rol');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en createRole: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtiene un rol por ID
  Future<Role?> getRoleById(int roleId, String token) async {
    try {
      final response = await _dio.get(
        '/roles/$roleId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Rol obtenido exitosamente');
        return Role.fromJson(response.data);
      } else {
        _logger.w('Error al obtener rol: ${response.data}');
        throw Exception('Error al obtener el rol');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getRoleById: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Actualiza un rol
  Future<Role?> updateRole(int roleId, String name, String token) async {
    try {
      final response = await _dio.put(
        '/roles/$roleId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'name': name,
        },
      );

      if (response.statusCode == 200) {
        _logger.i('Rol actualizado exitosamente');
        return Role.fromJson(response.data);
      } else {
        _logger.w('Error al actualizar rol: ${response.data}');
        throw Exception('Error al actualizar el rol');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en updateRole: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Elimina un rol por ID
  Future<void> deleteRole(int roleId, String token) async {
    try {
      final response = await _dio.delete(
        '/roles/$roleId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Rol eliminado exitosamente');
      } else {
        _logger.w('Error al eliminar rol: ${response.data}');
        throw Exception('Error al eliminar el rol');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en deleteRole: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtiene todos los roles con paginación
  Future<List<Role>> getAllRoles(int page, int perPage, String token) async {
    try {
      final response = await _dio.get(
        '/roles/',
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
        _logger.i('Roles obtenidos exitosamente');
        List<dynamic> rolesData = response.data as List<dynamic>;
        return rolesData.map((json) => Role.fromJson(json)).toList();
      } else {
        _logger.w('Error al obtener roles: ${response.data}');
        throw Exception('Error al obtener los roles');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getAllRoles: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
