import 'package:dio/dio.dart';
import 'package:lib_soma_front/config/domain/domain.dart';
import 'package:lib_soma_front/models/categorias.dart';
import 'package:logger/logger.dart';

class CategoryController {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  CategoryController() {
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

  // Crear una nueva categoría
  Future<Category?> createCategory(Category category, String token) async {
    try {
      final response = await _dio.post(
        '/categories/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: category.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i('Categoría creada exitosamente');
        return Category.fromJson(response.data);
      } else {
        _logger.w('Error al crear categoría: ${response.data}');
        throw Exception('Error al crear la categoría');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en createCategory: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener una categoría por ID
  Future<Category?> getCategoryById(int categoryId, String token) async {
    try {
      final response = await _dio.get(
        '/categories/$categoryId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        _logger.i('Categoría obtenida exitosamente');
        return Category.fromJson(response.data);
      } else {
        _logger.w('Error al obtener categoría: ${response.data}');
        throw Exception('Error al obtener la categoría');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getCategoryById: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener todas las categorías con paginación
  Future<List<Category>> getAllCategories(
      int page, int perPage, String token) async {
    try {
      final response = await _dio.get(
        '/categories/',
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
        _logger.i('Categorías obtenidas exitosamente');
        List<dynamic> categoriesData = response.data as List<dynamic>;
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      } else {
        _logger.w('Error al obtener categorías: ${response.data}');
        throw Exception('Error al obtener las categorías');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en getAllCategories: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Actualizar una categoría
  Future<Category?> updateCategory(
      int categoryId, Category category, String token) async {
    try {
      final response = await _dio.put(
        '/categories/$categoryId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: category.toJson(),
      );

      if (response.statusCode == 200) {
        _logger.i('Categoría actualizada exitosamente');
        return Category.fromJson(response.data);
      } else {
        _logger.w('Error al actualizar categoría: ${response.data}');
        throw Exception('Error al actualizar la categoría');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en updateCategory: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar una categoría
  Future<void> deleteCategory(int categoryId, String token) async {
    try {
      final response = await _dio.delete(
        '/categories/$categoryId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Categoría eliminada exitosamente');
      } else {
        _logger.w('Error al eliminar categoría: ${response.data}');
        throw Exception('Error al eliminar la categoría');
      }
    } catch (e) {
      _logger.e('Excepción atrapada en deleteCategory: ${e.toString()}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
