import 'package:dio/dio.dart';
import 'package:lib_soma_front/config/domain/domain.dart';
import 'package:lib_soma_front/models/multas.dart';
import 'package:logger/logger.dart';

class FineController {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  FineController() {
    _dio.options.baseUrl = baseUrl;

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.i('Solicitud: ${options.method} ${options.path}');
        _logger.d('Datos enviados: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i(
            'Respuesta recibida: ${response.statusCode} ${response.statusMessage}');
        _logger.d('Datos recibidos: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        _logger.e('Error en la solicitud: ${error.message}');
        if (error.response != null) {
          _logger.e('Datos de error: ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));
  }

  // Crear una nueva multa
  Future<Fine?> createFine(int userId, int loanId, double amount,
      String description, String token) async {
    try {
      final response = await _dio.post(
        '/fines/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'user_id': userId,
          'loan_id': loanId,
          'amount': amount,
          'description': description,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i('Multa creada exitosamente');
        return Fine.fromJson(response.data);
      } else {
        _logger.w('Error al crear multa: ${response.data}');
        throw Exception('Error al crear la multa');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en createFine: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener una multa por ID
  Future<Fine?> getFineById(int fineId, String token) async {
    try {
      final response = await _dio.get(
        '/fines/$fineId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        _logger.i('Multa obtenida exitosamente');
        return Fine.fromJson(response.data);
      } else {
        _logger.w('Error al obtener multa: ${response.data}');
        throw Exception('Error al obtener la multa');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getFineById: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Listar todas las multas con paginación
  Future<List<Fine>> listFines(String token,
      {int page = 1, int perPage = 10}) async {
    try {
      final response = await _dio.get(
        '/fines/',
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
        _logger.i('Multas obtenidas exitosamente');
        List<dynamic> finesData = response.data as List<dynamic>;
        return finesData.map((json) => Fine.fromJson(json)).toList();
      } else {
        _logger.w('Error al obtener multas: ${response.data}');
        throw Exception('Error al obtener las multas');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en listFines: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Marcar una multa como pagada
  Future<Fine?> payFine(int fineId, String token) async {
    try {
      final response = await _dio.put(
        '/fines/$fineId/pay',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Multa marcada como pagada exitosamente');
        return Fine.fromJson(response.data);
      } else {
        _logger.w('Error al pagar multa: ${response.data}');
        throw Exception('Error al pagar la multa');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en payFine: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar una multa por ID
  Future<void> deleteFine(int fineId, String token) async {
    try {
      final response = await _dio.delete(
        '/fines/$fineId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Multa eliminada exitosamente');
      } else {
        _logger.w('Error al eliminar multa: ${response.data}');
        throw Exception('Error al eliminar la multa');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en deleteFine: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener todas las multas de un usuario por su ID
  Future<List<Fine>> getUserFines(int userId, String token) async {
    try {
      final response = await _dio.get(
        '/fines/user/$userId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Multas del usuario obtenidas exitosamente');
        List<dynamic> finesData = response.data as List<dynamic>;
        return finesData.map((json) => Fine.fromJson(json)).toList();
      } else {
        _logger.w('Error al obtener multas del usuario: ${response.data}');
        throw Exception('Error al obtener las multas del usuario');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getUserFines: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
