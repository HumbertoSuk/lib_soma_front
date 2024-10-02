import 'package:dio/dio.dart';
import 'package:lib_soma_front/config/domain/domain.dart';
import 'package:lib_soma_front/models/books.dart';
import 'package:logger/logger.dart';

class BookController {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  BookController() {
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

  // Crear un nuevo libro
  Future<Book?> createBook(Book book, String token) async {
    try {
      final response = await _dio.post(
        '/books/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: book.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i('Libro creado exitosamente');
        return Book.fromJson(response.data);
      } else {
        _logger.w('Error al crear libro: ${response.data}');
        throw Exception('Error al crear el libro');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en createBook: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener un libro por ID
  Future<Book?> getBookById(int bookId, String token) async {
    try {
      final response = await _dio.get(
        '/books/$bookId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        _logger.i('Libro obtenido exitosamente');
        return Book.fromJson(response.data);
      } else {
        _logger.w('Error al obtener libro: ${response.data}');
        throw Exception('Error al obtener el libro');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getBookById: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener todos los libros con paginación
  Future<List<Book>> getAllBooks(int page, int perPage, String token) async {
    try {
      final response = await _dio.get(
        '/books/',
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
        _logger.i('Libros obtenidos exitosamente');
        List<dynamic> booksData = response.data as List<dynamic>;
        return booksData.map((json) => Book.fromJson(json)).toList();
      } else {
        _logger.w('Error al obtener libros: ${response.data}');
        throw Exception('Error al obtener los libros');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getAllBooks: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Actualizar un libro
  Future<Book?> updateBook(int bookId, Book book, String token) async {
    try {
      final response = await _dio.put(
        '/books/$bookId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: book.toJson(),
      );

      if (response.statusCode == 200) {
        _logger.i('Libro actualizado exitosamente');
        return Book.fromJson(response.data);
      } else {
        _logger.w('Error al actualizar libro: ${response.data}');
        throw Exception('Error al actualizar el libro');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en updateBook: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar un libro
  Future<void> deleteBook(int bookId, String token) async {
    try {
      final response = await _dio.delete(
        '/books/$bookId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Libro eliminado exitosamente');
      } else {
        _logger.w('Error al eliminar libro: ${response.data}');
        throw Exception('Error al eliminar el libro');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en deleteBook: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener la disponibilidad del libro (copias disponibles)
  Future<int> getBookAvailability(int bookId, String token) async {
    try {
      final response = await _dio.get(
        '/books/$bookId/availability',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Disponibilidad del libro obtenida exitosamente');
        return response.data['available_copies'];
      } else {
        _logger
            .w('Error al obtener disponibilidad del libro: ${response.data}');
        throw Exception('Error al obtener la disponibilidad del libro');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getBookAvailability: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
