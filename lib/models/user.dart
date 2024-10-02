class UserModel {
  final int? id; // El ID puede ser nulo en algunos casos (ej: creación)
  final String username;
  final String email;
  final String? password; // El password es opcional en algunos casos
  final int roleId; // roleId debe ser un entero

  UserModel({
    this.id,
    required this.username,
    this.password,
    required this.email,
    required this.roleId, // El rol es obligatorio
  });

  // Convertir un UserModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'role_id': roleId, // Enviar solo el ID del rol
    };
  }

  // Convertir de JSON a un UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'],
      email: json['email'],
      password: json['password']
          as String?, // El password puede no estar presente en algunas respuestas
      roleId: json['role_id']
          as int, // role_id es obligatorio y siempre debe ser un entero
    );
  }
}
