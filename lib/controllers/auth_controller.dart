import 'package:dio/dio.dart';
import 'package:lib_soma_front/config/domain/domain.dart';
import 'package:logger/logger.dart';

class AuthController {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  AuthController() {
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

// Inicia sesión y devuelve un Map con token, userId y roleId
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final formData = {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'scope': '',
        'client_id': 'string',
        'client_secret': 'string',
      };

      final response = await _dio.post(
        '/token/',
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: formData,
      );

      if (response.statusCode == 200) {
        _logger.i('Inicio de sesión exitoso');
        return {
          'access_token': response.data['access_token'], // Token de acceso
          'user_id': response.data['user_id'], // ID del usuario
          'role_id': response.data['role_id'], // ID del rol
        };
      } else {
        _logger.w('Error al iniciar sesión: ${response.data}');
        throw Exception('Usuario o contraseña incorrectos');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en login: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
