import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lib_soma_front/controllers/reservaciones_controller.dart';
import 'package:lib_soma_front/models/reservaciones.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

final reservationProvider = ChangeNotifierProvider<ReservationNotifier>((ref) {
  final authNotifier = ref.watch(authProvider);
  return ReservationNotifier(authNotifier.token, authNotifier.userId);
});

class ReservationNotifier extends ChangeNotifier {
  final ReservationController _reservationController = ReservationController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<BookReservation> _reservations = [];
  BookReservation? _selectedReservation;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BookReservation> get reservations => _reservations;
  BookReservation? get selectedReservation => _selectedReservation;

  String? _token;
  final int? _userId; // Almacenar el ID del usuario autenticado

  ReservationNotifier(this._token, this._userId);

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

  // Cargar el token almacenado si no está disponible
  Future<void> _loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
  }

  // Obtener todas las reservaciones
  Future<void> fetchReservations(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token == null) {
        await _loadToken();
      }

      if (_token != null) {
        final reservations =
            await _reservationController.listReservations(_token!);
        _reservations = reservations;
        _showSnackBar(context, 'Reservaciones cargadas correctamente');
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al obtener las reservaciones: $e',
          isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear una nueva reservación utilizando el userId autenticado
  Future<void> createReservation(int bookId, BuildContext context) async {
    if (_userId == null) {
      _showSnackBar(context, 'No se ha encontrado el ID de usuario autenticado',
          isError: true);
      return;
    }

    try {
      if (_token == null) {
        await _loadToken();
      }

      if (_token != null) {
        final newReservation = await _reservationController.createReservation(
            _userId!, bookId, _token!);
        if (newReservation != null) {
          _reservations.add(newReservation);
          _showSnackBar(context, 'Reservación creada correctamente');
          notifyListeners();
        }
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al crear la reservación: ${e.toString()}',
          isError: true);
    }
  }

  // Método para marcar una reservación como cumplida
  Future<void> fulfillReservation(
      int reservationId, BuildContext context) async {
    try {
      if (_token == null) {
        await _loadToken();
      }

      if (_token != null) {
        await _reservationController.fulfillReservation(reservationId, _token!);
        _reservations = _reservations.map((reservation) {
          if (reservation.id == reservationId) {
            reservation.active = false; // Marcar como cumplida
          }
          return reservation;
        }).toList();

        _showSnackBar(context, 'Reservación marcada como cumplida.');
        notifyListeners();
      } else {
        throw Exception('No se ha encontrado el token de autenticación');
      }
    } catch (e) {
      _showSnackBar(
        context,
        'Error al marcar la reservación como cumplida: ${e.toString()}',
        isError: true,
      );
    }
  }

  // Otros métodos de actualización, eliminación, etc., también utilizan _userId y _token
}
