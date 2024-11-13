class Loan {
  final int id;
  final int? userId; // Solo el ID del usuario
  final int? bookId; // Solo el ID del libro
  final DateTime loanDate;
  final DateTime? returnDate; // La fecha de devolución es opcional
  final bool returned;

  Loan({
    required this.id,
    this.userId, // ID del usuario
    this.bookId, // ID del libro
    required this.loanDate,
    this.returnDate,
    required this.returned,
  });

  // Convertir un préstamo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId, // Solo ID de usuario
      'book_id': bookId, // Solo ID de libro
      'loan_date': loanDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'returned': returned,
    };
  }

  // Convertir de JSON a un préstamo
  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      userId: json['user_id'], // Obtener ID de usuario
      bookId: json['book_id'], // Obtener ID de libro
      loanDate: DateTime.parse(json['loan_date']),
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'])
          : null,
      returned: json['returned'],
    );
  }
}
