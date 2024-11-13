import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lib_soma_front/controllers/prestamo_controller.dart';
import 'package:lib_soma_front/models/historial_prestamos.dart';
import 'package:lib_soma_front/models/prestamo.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

final loanProvider = ChangeNotifierProvider<LoanNotifier>((ref) {
  final authNotifier = ref.watch(authProvider);
  return LoanNotifier(authNotifier.token, authNotifier.userId);
});

class LoanNotifier extends ChangeNotifier {
  final LoanController _loanController = LoanController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<Loan> _loans = [];
  Loan? _selectedLoan;
  List<LoanHistory> _loanHistory = [];
  LoanHistory? _selectedLoanHistory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Loan> get loans => _loans;
  Loan? get selectedLoan => _selectedLoan;
  List<LoanHistory> get loanHistory => _loanHistory;
  LoanHistory? get selectedLoanHistory => _selectedLoanHistory;

  String? _token;
  int? _userId;

  LoanNotifier(this._token, this._userId);

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _loadCredentials() async {
    _token = await _secureStorage.read(key: 'auth_token');
    _userId = int.tryParse(await _secureStorage.read(key: 'user_id') ?? '');
  }

  // Obtener todos los préstamos
  Future<void> fetchLoans(BuildContext context,
      {int page = 1, int perPage = 10}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token == null || _userId == null) await _loadCredentials();

      if (_token != null) {
        final loans = await _loanController.getAllLoans(_token!,
            page: page, perPage: perPage);
        _loans = loans;
        _showSnackBar(context, 'Préstamos cargados correctamente');
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener los préstamos: $e',
          isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear un nuevo préstamo utilizando userId
  Future<void> createLoan(int bookId, BuildContext context) async {
    if (_userId == null) {
      _showSnackBar(context, 'No se ha encontrado el ID de usuario autenticado',
          isError: true);
      return;
    }

    try {
      if (_token == null) await _loadCredentials();

      if (_token != null) {
        final newLoan =
            await _loanController.createLoan(_userId!, bookId, _token!);
        if (newLoan != null) {
          _loans.add(newLoan);
          _showSnackBar(context, 'Préstamo creado correctamente');
          notifyListeners();
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al crear el préstamo: ${e.toString()}',
          isError: true);
    }
  }

  // Obtener un préstamo específico por su ID
  Future<void> getLoanById(int loanId, BuildContext context) async {
    try {
      if (_token == null) await _loadCredentials();

      if (_token != null) {
        final loan = await _loanController.getLoanById(loanId, _token!);
        _selectedLoan = loan;
        notifyListeners();
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener el préstamo: ${e.toString()}',
          isError: true);
    }
  }

  // Marcar un préstamo como devuelto
  Future<void> returnLoan(int loanId, BuildContext context) async {
    try {
      if (_token == null) await _loadCredentials();

      if (_token != null) {
        final returnedLoan = await _loanController.returnBook(loanId, _token!);
        if (returnedLoan != null) {
          final index = _loans.indexWhere((loan) => loan.id == loanId);
          if (index != -1) {
            _loans[index] = returnedLoan;
            _showSnackBar(context, 'Préstamo marcado como devuelto');
            notifyListeners();
          }
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(
          context, 'Error al marcar el préstamo como devuelto: ${e.toString()}',
          isError: true);
    }
  }

  // Eliminar un préstamo
  Future<void> deleteLoan(int loanId, BuildContext context) async {
    try {
      if (_token == null) await _loadCredentials();

      if (_token != null) {
        await _loanController.deleteLoan(loanId, _token!);
        _loans.removeWhere((loan) => loan.id == loanId);
        _showSnackBar(context, 'Préstamo eliminado correctamente');
        notifyListeners();
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al eliminar el préstamo: ${e.toString()}',
          isError: true);
    }
  }

  // Calcular multa por retraso
  Future<void> calculateLateFee(int loanId, BuildContext context) async {
    try {
      if (_token == null) await _loadCredentials();

      if (_token != null) {
        final lateFee = await _loanController.calculateLateFee(loanId, _token!);
        _showSnackBar(
            context, 'Multa por retraso: \$${lateFee.toStringAsFixed(2)}');
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(
          context, 'Error al calcular la multa por retraso: ${e.toString()}',
          isError: true);
    }
  }

  // Obtener historial de préstamos
  Future<void> fetchLoanHistory(BuildContext context,
      {int page = 1, int perPage = 10}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token == null) await _loadCredentials();

      if (_token != null) {
        final history = await _loanController.getLoanHistory(_token!,
            page: page, perPage: perPage);
        _loanHistory = history;
        _showSnackBar(context, 'Historial de préstamos cargado correctamente');
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener el historial de préstamos: $e',
          isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar el préstamo seleccionado
  void clearSelectedLoan() {
    _selectedLoan = null;
    _selectedLoanHistory = null;
    notifyListeners();
  }
}
