class Book {
  final int? id;
  final String title;
  final String author;
  final int categoryId;
  final String isbn;
  final int copiesAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.categoryId,
    required this.isbn,
    required this.copiesAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convertir un libro a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category_id': categoryId,
      'isbn': isbn,
      'copies_available': copiesAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convertir de JSON a un libro
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      categoryId: json['category_id'],
      isbn: json['isbn'],
      copiesAvailable: json['copies_available'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
