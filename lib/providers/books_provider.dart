import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lib_soma_front/controllers/books_controller.dart';
import 'package:lib_soma_front/models/books.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

final bookProvider = ChangeNotifierProvider<BookNotifier>((ref) {
  final authNotifier =
      ref.watch(authProvider); // Escuchar el estado de autenticación
  return BookNotifier(authNotifier.token); // Pasar el token al BookNotifier
});

class BookNotifier extends ChangeNotifier {
  final BookController _bookController = BookController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<Book> _books = [];
  Book? _selectedBook;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Book> get books => _books;
  Book? get selectedBook => _selectedBook;

  String? _token;

  BookNotifier(this._token);

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

  // Cargar el token almacenado al inicializar el BookNotifier
  Future<void> _loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
  }

  // Método para obtener todos los libros
  Future<void> fetchBooks(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final books = await _bookController.getAllBooks(1, 40, _token!);
        _books = books;
        _showSnackBar(context, 'Libros cargados correctamente');
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener los libros: $e', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners(); // Notificar cambios en la UI
    }
  }

  // Método para crear un libro
  Future<void> createBook(Book book, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final newBook = await _bookController.createBook(book, _token!);
        if (newBook != null) {
          _books.add(newBook);
          _showSnackBar(context, 'Libro creado correctamente');
          notifyListeners(); // Notificar cambios en la lista de libros
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al crear el libro: ${e.toString()}',
          isError: true);
    }
  }

  // Método para actualizar un libro
  Future<void> updateBook(int bookId, Book book, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final updatedBook =
            await _bookController.updateBook(bookId, book, _token!);
        if (updatedBook != null) {
          // Reemplazar el libro actualizado en la lista de libros
          final index = _books.indexWhere((b) => b.id == bookId);
          if (index != -1) {
            _books[index] = updatedBook;
            _showSnackBar(context, 'Libro actualizado correctamente');
            notifyListeners();
          }
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al actualizar el libro: ${e.toString()}',
          isError: true);
    }
  }

  // Método para eliminar un libro
  Future<void> deleteBook(int bookId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        await _bookController.deleteBook(bookId, _token!);
        // Eliminar el libro de la lista
        _books.removeWhere((book) => book.id == bookId);
        _showSnackBar(context, 'Libro eliminado correctamente');
        notifyListeners();
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al eliminar el libro: ${e.toString()}',
          isError: true);
    }
  }

  // Método para obtener un libro específico por su ID
  Future<void> getBookById(int bookId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final book = await _bookController.getBookById(bookId, _token!);
        _selectedBook = book;
        notifyListeners(); // Notificar que se seleccionó un nuevo libro
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener el libro: ${e.toString()}',
          isError: true);
    }
  }

  // Método para obtener la disponibilidad de un libro
  Future<void> getBookAvailability(int bookId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken(); // Cargar token si no está disponible
      }

      if (_token != null) {
        final availableCopies =
            await _bookController.getBookAvailability(bookId, _token!);
        _showSnackBar(context,
            'Copias disponibles: $availableCopies'); // Mostrar disponibilidad
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(
          context, 'Error al obtener la disponibilidad: ${e.toString()}',
          isError: true);
    }
  }

  // Limpiar el libro seleccionado
  void clearSelectedBook() {
    _selectedBook = null;
    notifyListeners();
  }
}
