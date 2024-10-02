class Role {
  final int id;
  final String name;

  Role({
    required this.id,
    required this.name,
  });

  // Método para convertir de JSON a un objeto Role
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
    );
  }

  // Método para convertir un objeto Role a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
