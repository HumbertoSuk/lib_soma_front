import 'package:lib_soma_front/models/books.dart';
import 'package:lib_soma_front/models/user.dart';

class BookReservation {
  final int id;
  final UserModel? user; // Relación con el modelo de User
  final Book? book; // Relación con el modelo de Book
  final DateTime reservationDate;
  final bool active; // Estado de la reserva

  BookReservation({
    required this.id,
    this.user, // Relación opcional con el usuario
    this.book, // Relación opcional con el libro
    required this.reservationDate,
    required this.active,
  });

  // Convertir la reserva de libro a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(), // Serializar la relación de usuario
      'book': book?.toJson(), // Serializar la relación de libro
      'reservation_date': reservationDate.toIso8601String(),
      'active': active,
    };
  }

  // Convertir de JSON a una reserva de libro
  factory BookReservation.fromJson(Map<String, dynamic> json) {
    return BookReservation(
      id: json['id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      book: json['book'] != null ? Book.fromJson(json['book']) : null,
      reservationDate: DateTime.parse(json['reservation_date']),
      active: json['active'],
    );
  }
}
