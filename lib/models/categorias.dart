class Category {
  final int? id;
  final String name;

  Category({
    this.id,
    required this.name,
  });

  // Convertir una categoría a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Convertir de JSON a una categoría
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}
