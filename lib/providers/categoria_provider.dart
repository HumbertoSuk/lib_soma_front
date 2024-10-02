import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lib_soma_front/controllers/categorias_controller.dart';
import 'package:lib_soma_front/models/categorias.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

final categoryProvider = ChangeNotifierProvider<CategoryNotifier>((ref) {
  final authNotifier =
      ref.watch(authProvider); // Escuchar el estado de autenticación
  return CategoryNotifier(
      authNotifier.token); // Pasar el token al CategoryNotifier
});

class CategoryNotifier extends ChangeNotifier {
  final CategoryController _categoryController = CategoryController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<Category> _categories = [];
  Category? _selectedCategory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;

  String? _token;

  CategoryNotifier(this._token);

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

  // Cargar el token almacenado al inicializar el CategoryNotifier
  Future<void> _loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
  }

  // Método para obtener todas las categorías
  Future<void> fetchCategories(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final categories =
            await _categoryController.getAllCategories(1, 40, _token!);
        _categories = categories;
        _showSnackBar(context, 'Categorías cargadas correctamente');
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener las categorías: $e',
          isError: true);
    } finally {
      _isLoading = false;
      notifyListeners(); // Notificar cambios en la UI
    }
  }

  // Método para crear una categoría
  Future<void> createCategory(Category category, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final newCategory =
            await _categoryController.createCategory(category, _token!);
        if (newCategory != null) {
          _categories.add(newCategory);
          _showSnackBar(context, 'Categoría creada correctamente');
          notifyListeners(); // Notificar cambios en la lista de categorías
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al crear la categoría: ${e.toString()}',
          isError: true);
    }
  }

  // Método para actualizar una categoría
  Future<void> updateCategory(
      int categoryId, Category category, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final updatedCategory = await _categoryController.updateCategory(
            categoryId, category, _token!);
        if (updatedCategory != null) {
          // Reemplazar la categoría actualizada en la lista de categorías
          final index = _categories.indexWhere((c) => c.id == categoryId);
          if (index != -1) {
            _categories[index] = updatedCategory;
            _showSnackBar(context, 'Categoría actualizada correctamente');
            notifyListeners();
          }
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(
          context, 'Error al actualizar la categoría: ${e.toString()}',
          isError: true);
    }
  }

  // Método para eliminar una categoría
  Future<void> deleteCategory(int categoryId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        await _categoryController.deleteCategory(categoryId, _token!);
        // Eliminar la categoría de la lista
        _categories.removeWhere((category) => category.id == categoryId);
        _showSnackBar(context, 'Categoría eliminada correctamente');
        notifyListeners();
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al eliminar la categoría: ${e.toString()}',
          isError: true);
    }
  }

  // Método para obtener una categoría específica por su ID
  Future<void> getCategoryById(int categoryId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final category =
            await _categoryController.getCategoryById(categoryId, _token!);
        _selectedCategory = category;
        notifyListeners(); // Notificar que se seleccionó una nueva categoría
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener la categoría: ${e.toString()}',
          isError: true);
    }
  }

  // Limpiar la categoría seleccionada
  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }
}
