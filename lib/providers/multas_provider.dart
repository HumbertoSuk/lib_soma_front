import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lib_soma_front/controllers/multas_controller.dart';
import 'package:lib_soma_front/models/multas.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

final fineProvider = ChangeNotifierProvider<FineNotifier>((ref) {
  final authNotifier =
      ref.watch(authProvider); // Escuchar el estado de autenticación
  return FineNotifier(authNotifier.token); // Pasar el token a FineNotifier
});

class FineNotifier extends ChangeNotifier {
  final FineController _fineController = FineController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<Fine> _fines = [];
  Fine? _selectedFine;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Fine> get fines => _fines;
  Fine? get selectedFine => _selectedFine;

  String? _token;

  FineNotifier(this._token);

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

  // Cargar el token almacenado
  Future<void> _loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
  }

  // Obtener todas las multas
  Future<void> fetchFines(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token == null) {
        await _loadToken();
      }

      if (_token != null) {
        final fines = await _fineController.listFines(_token!);
        _fines = fines;
        _showSnackBar(context, 'Multas cargadas correctamente');
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener las multas: $e', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear una nueva multa
  Future<void> createFine(int userId, int loanId, double amount,
      String description, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken();
      }

      if (_token != null) {
        final newFine = await _fineController.createFine(
            userId, loanId, amount, description, _token!);
        if (newFine != null) {
          _fines.add(newFine);
          _showSnackBar(context, 'Multa creada correctamente');
          notifyListeners();
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al crear la multa: ${e.toString()}',
          isError: true);
    }
  }

  // Obtener una multa específica por su ID
  Future<void> getFineById(int fineId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken();
      }

      if (_token != null) {
        final fine = await _fineController.getFineById(fineId, _token!);
        _selectedFine = fine;
        notifyListeners();
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener la multa: ${e.toString()}',
          isError: true);
    }
  }

  // Marcar una multa como pagada
  Future<void> payFine(int fineId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken();
      }

      if (_token != null) {
        final paidFine = await _fineController.payFine(fineId, _token!);
        if (paidFine != null) {
          final index = _fines.indexWhere((f) => f.id == fineId);
          if (index != -1) {
            _fines[index] = paidFine;
            _showSnackBar(context, 'Multa marcada como pagada');
            notifyListeners();
          }
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(
          context, 'Error al marcar la multa como pagada: ${e.toString()}',
          isError: true);
    }
  }

  // Eliminar una multa
  Future<void> deleteFine(int fineId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken();
      }

      if (_token != null) {
        await _fineController.deleteFine(fineId, _token!);
        _fines.removeWhere((fine) => fine.id == fineId);
        _showSnackBar(context, 'Multa eliminada correctamente');
        notifyListeners();
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al eliminar la multa: ${e.toString()}',
          isError: true);
    }
  }

  // Obtener multas de un usuario específico
  Future<void> getUserFines(int userId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken();
      }

      if (_token != null) {
        final userFines = await _fineController.getUserFines(userId, _token!);
        _fines = userFines;
        _showSnackBar(context, 'Multas del usuario obtenidas correctamente');
        notifyListeners();
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(
          context, 'Error al obtener las multas del usuario: ${e.toString()}',
          isError: true);
    }
  }

  // Limpiar la multa seleccionada
  void clearSelectedFine() {
    _selectedFine = null;
    notifyListeners();
  }
}
