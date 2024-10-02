import 'package:lib_soma_front/models/prestamo.dart';
import 'package:lib_soma_front/models/user.dart';

class Fine {
  final int id;
  final UserModel? user; // Relación con el modelo de Usuario
  final Loan? loan; // Relación con el modelo de Préstamo
  final double amount; // Monto de la multa
  final String description; // Descripción de la multa
  final bool paid; // Estado de pago de la multa
  final DateTime fineDate; // Fecha de la multa

  Fine({
    required this.id,
    this.user, // Relación opcional con el usuario
    this.loan, // Relación opcional con el préstamo
    required this.amount,
    required this.description,
    required this.paid,
    required this.fineDate,
  });

  // Convertir la multa a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(), // Serializar la relación de usuario
      'loan': loan?.toJson(), // Serializar la relación de préstamo
      'amount': amount,
      'description': description,
      'paid': paid,
      'fine_date': fineDate.toIso8601String(),
    };
  }

  // Convertir de JSON a una multa
  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: json['id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      loan: json['loan'] != null ? Loan.fromJson(json['loan']) : null,
      amount: double.parse(json['amount'].toString()),
      description: json['description'],
      paid: json['paid'],
      fineDate: DateTime.parse(json['fine_date']),
    );
  }
}
