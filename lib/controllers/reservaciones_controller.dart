import 'package:dio/dio.dart';
import 'package:lib_soma_front/config/domain/domain.dart';
import 'package:lib_soma_front/models/reservaciones.dart';
import 'package:logger/logger.dart';

class ReservationController {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  ReservationController() {
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

  // Crear una nueva reservación
  Future<BookReservation?> createReservation(
      int userId, int bookId, String token) async {
    try {
      final response = await _dio.post(
        '/book-reservations/',
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
        _logger.i('Reservación creada exitosamente');
        return BookReservation.fromJson(response.data);
      } else {
        _logger.w('Error al crear reservación: ${response.data}');
        throw Exception('Error al crear la reservación');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en createReservation: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener una reservación por ID
  Future<BookReservation?> getReservationById(
      int reservationId, String token) async {
    try {
      final response = await _dio.get(
        '/book-reservations/$reservationId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        _logger.i('Reservación obtenida exitosamente');
        return BookReservation.fromJson(response.data);
      } else {
        _logger.w('Error al obtener reservación: ${response.data}');
        throw Exception('Error al obtener la reservación');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getReservationById: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Listar todas las reservaciones
  Future<List<BookReservation>> listReservations(String token) async {
    try {
      final response = await _dio.get(
        '/book-reservations/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Reservaciones obtenidas exitosamente');
        List<dynamic> reservationsData = response.data as List<dynamic>;
        return reservationsData
            .map((json) => BookReservation.fromJson(json))
            .toList();
      } else {
        _logger.w('Error al obtener reservaciones: ${response.data}');
        throw Exception('Error al obtener las reservaciones');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en listReservations: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Actualizar una reservación
  Future<BookReservation?> updateReservation(
      int reservationId, int userId, int bookId, String token) async {
    try {
      final response = await _dio.put(
        '/book-reservations/$reservationId/',
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

      if (response.statusCode == 200) {
        _logger.i('Reservación actualizada exitosamente');
        return BookReservation.fromJson(response.data);
      } else {
        _logger.w('Error al actualizar reservación: ${response.data}');
        throw Exception('Error al actualizar la reservación');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en updateReservation: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar una reservación
  Future<void> deleteReservation(int reservationId, String token) async {
    try {
      final response = await _dio.delete(
        '/book-reservations/$reservationId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Reservación eliminada exitosamente');
      } else {
        _logger.w('Error al eliminar reservación: ${response.data}');
        throw Exception('Error al eliminar la reservación');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en deleteReservation: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener reservaciones activas de un usuario
  Future<List<BookReservation>> getUserReservations(
      int userId, String token) async {
    try {
      final response = await _dio.get(
        '/reservations/user/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Reservaciones activas del usuario obtenidas exitosamente');
        List<dynamic> reservationsData = response.data as List<dynamic>;
        return reservationsData
            .map((json) => BookReservation.fromJson(json))
            .toList();
      } else {
        _logger
            .w('Error al obtener reservaciones del usuario: ${response.data}');
        throw Exception('Error al obtener las reservaciones del usuario');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getUserReservations: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Reservar un libro (si hay disponibilidad)
  Future<void> reserveBook(int userId, int bookId, String token) async {
    try {
      final response = await _dio.post(
        '/reservations/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'user_id': userId,
          'book_id': bookId,
        },
      );

      if (response.statusCode == 200) {
        _logger.i('Libro reservado exitosamente');
      } else {
        _logger.w('Error al reservar libro: ${response.data}');
        throw Exception('Error al reservar el libro');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en reserveBook: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Método para cumplir una reservación y actualizar las copias disponibles
  Future<void> fulfillReservation(int reservationId, String token) async {
    try {
      final response = await _dio.put(
        '/book-reservations/$reservationId/fulfill',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i(
            'Reservación marcada como cumplida y copias actualizadas exitosamente');
      } else {
        _logger.w('Error al cumplir la reservación: ${response.data}');
        throw Exception('Error al cumplir la reservación');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en fulfillReservation: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
