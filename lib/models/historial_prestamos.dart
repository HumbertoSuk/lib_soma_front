class LoanHistory {
  final int id;
  final int? userId; // ID del usuario
  final int? bookId; // ID del libro
  final DateTime loanDate;
  final DateTime? returnDate; // La fecha de devolución es opcional
  final bool returned;

  LoanHistory({
    required this.id,
    this.userId, // ID opcional del usuario
    this.bookId, // ID opcional del libro
    required this.loanDate,
    this.returnDate,
    required this.returned,
  });

  // Convertir el historial de préstamo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId, // Serializar solo el ID de usuario
      'book_id': bookId, // Serializar solo el ID del libro
      'loan_date': loanDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'returned': returned,
    };
  }

  // Convertir de JSON a un historial de préstamo
  factory LoanHistory.fromJson(Map<String, dynamic> json) {
    return LoanHistory(
      id: json['id'],
      userId: json['user_id'],
      bookId: json['book_id'],
      loanDate: DateTime.parse(json['loan_date']),
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'])
          : null,
      returned: json['returned'],
    );
  }
}
