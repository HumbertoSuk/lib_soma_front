import 'package:lib_soma_front/models/books.dart';
import 'package:lib_soma_front/models/user.dart';

class LoanHistory {
  final int id;
  final UserModel? user; // Relación con el modelo de User
  final Book? book; // Relación con el modelo de Book
  final DateTime loanDate;
  final DateTime? returnDate; // La fecha de devolución es opcional
  final bool returned;

  LoanHistory({
    required this.id,
    this.user, // Relación opcional con el usuario
    this.book, // Relación opcional con el libro
    required this.loanDate,
    this.returnDate,
    required this.returned,
  });

  // Convertir el historial de préstamo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(), // Serializar la relación de usuario
      'book': book?.toJson(), // Serializar la relación de libro
      'loan_date': loanDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'returned': returned,
    };
  }

  // Convertir de JSON a un historial de préstamo
  factory LoanHistory.fromJson(Map<String, dynamic> json) {
    return LoanHistory(
      id: json['id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      book: json['book'] != null ? Book.fromJson(json['book']) : null,
      loanDate: DateTime.parse(json['loan_date']),
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'])
          : null,
      returned: json['returned'],
    );
  }
}
