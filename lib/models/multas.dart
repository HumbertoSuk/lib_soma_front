class Fine {
  final int id;
  final int userId; // Identificador del usuario asociado
  final int loanId; // Identificador del préstamo asociado
  final double amount; // Monto de la multa
  final String description; // Descripción de la multa
  final bool paid; // Estado de pago de la multa
  final DateTime fineDate; // Fecha en la que se registró la multa

  Fine({
    required this.id,
    required this.userId,
    required this.loanId,
    required this.amount,
    required this.description,
    required this.paid,
    required this.fineDate,
  });

  // Convertir la multa a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId, // Serializar el ID de usuario
      'loan_id': loanId, // Serializar el ID de préstamo
      'amount': amount,
      'description': description,
      'paid': paid,
      'fine_date': fineDate.toIso8601String(),
    };
  }

  // Convertir de JSON a una instancia de multa
  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: json['id'],
      userId: json['user_id'],
      loanId: json['loan_id'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'],
      paid: json['paid'],
      fineDate: DateTime.parse(json['fine_date']),
    );
  }
}
