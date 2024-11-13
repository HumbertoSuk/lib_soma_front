import 'package:dio/dio.dart';
import 'package:lib_soma_front/config/domain/domain.dart';
import 'package:lib_soma_front/models/historial_prestamos.dart';
import 'package:lib_soma_front/models/prestamo.dart';
import 'package:logger/logger.dart';

class LoanController {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  LoanController() {
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

  // Crear un nuevo préstamo
  Future<Loan?> createLoan(int userId, int bookId, String token) async {
    try {
      final response = await _dio.post(
        '/loans/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'user_id': userId,
          'book_id': bookId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i('Préstamo creado exitosamente');
        return Loan.fromJson(response.data);
      } else {
        _logger.w('Error al crear préstamo: ${response.data}');
        throw Exception('Error al crear el préstamo');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en createLoan: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Marcar un préstamo como devuelto
  Future<Loan?> returnBook(int loanId, String token) async {
    try {
      final response = await _dio.put(
        '/loans/$loanId/return',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Préstamo marcado como devuelto exitosamente');
        return Loan.fromJson(response.data);
      } else {
        _logger.w('Error al devolver préstamo: ${response.data}');
        throw Exception('Error al devolver el préstamo');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en returnBook: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener todos los préstamos con paginación
  Future<List<Loan>> getAllLoans(String token,
      {int page = 1, int perPage = 10}) async {
    try {
      final response = await _dio.get(
        '/loans/',
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
        _logger.i('Préstamos obtenidos exitosamente');
        List<dynamic> loansData = response.data as List<dynamic>;
        return loansData.map((json) => Loan.fromJson(json)).toList();
      } else {
        _logger.w('Error al obtener préstamos: ${response.data}');
        throw Exception('Error al obtener los préstamos');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getAllLoans: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener un préstamo por ID
  Future<Loan?> getLoanById(int loanId, String token) async {
    try {
      final response = await _dio.get(
        '/loans/$loanId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        _logger.i('Préstamo obtenido exitosamente');
        return Loan.fromJson(response.data);
      } else {
        _logger.w('Error al obtener préstamo: ${response.data}');
        throw Exception('Error al obtener el préstamo');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getLoanById: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar un préstamo
  Future<void> deleteLoan(int loanId, String token) async {
    try {
      final response = await _dio.delete(
        '/loans/$loanId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Préstamo eliminado exitosamente');
      } else {
        _logger.w('Error al eliminar préstamo: ${response.data}');
        throw Exception('Error al eliminar el préstamo');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en deleteLoan: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Calcular multa por retraso
  Future<double> calculateLateFee(int loanId, String token) async {
    try {
      final response = await _dio.get(
        '/loans/$loanId/late_fee',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Multa por retraso calculada exitosamente');
        return response.data['late_fee'] as double;
      } else {
        _logger.w('Error al calcular multa: ${response.data}');
        throw Exception('Error al calcular la multa por retraso');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en calculateLateFee: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener historial de préstamos con paginación
  Future<List<LoanHistory>> getLoanHistory(String token,
      {int page = 1, int perPage = 10}) async {
    try {
      final response = await _dio.get(
        '/loans/history',
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
        _logger.i('Historial de préstamos obtenido exitosamente');
        List<dynamic> historyData = response.data as List<dynamic>;
        return historyData.map((json) => LoanHistory.fromJson(json)).toList();
      } else {
        _logger.w('Error al obtener historial de préstamos: ${response.data}');
        throw Exception('Error al obtener el historial de préstamos');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getLoanHistory: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener historial de un préstamo específico por ID
  Future<LoanHistory?> getLoanHistoryById(int loanId, String token) async {
    try {
      final response = await _dio.get(
        '/loans/history/$loanId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        _logger.i('Historial de préstamo obtenido exitosamente');
        return LoanHistory.fromJson(response.data);
      } else {
        _logger.w('Error al obtener historial de préstamo: ${response.data}');
        throw Exception('Error al obtener el historial de préstamo');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getLoanHistoryById: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
