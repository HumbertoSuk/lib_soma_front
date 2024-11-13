class BookReservation {
  final int id;
  final int? user; // Relación con el modelo de User
  final int? book; // Relación con el modelo de Book
  final DateTime reservationDate;
  bool active; // Estado de la reserva

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
      'user_id': user, // Serializar la relación de usuario
      'book_id': book, // Serializar la relación de libro
      'reservation_date': reservationDate.toIso8601String(),
      'active': active,
    };
  }

  // Convertir de JSON a una reserva de libro
  factory BookReservation.fromJson(Map<String, dynamic> json) {
    return BookReservation(
      id: json['id'],
      user: json['user_id'],
      book: json['book_id'],
      reservationDate: DateTime.parse(json['reservation_date']),
      active: json['active'],
    );
  }
}
