import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/providers/user_provider.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  @override
  void initState() {
    super.initState();
    _refreshUsers(); // Cargar la lista de usuarios al inicializar la pantalla
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Botón de "Actualizar"
            onPressed: _refreshUsers, // Llamar al método de refresh
          ),
        ],
      ),
      body: userNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.go(
                          '/home/users/new'); // Navegar a la creación de usuario
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Crear Nuevo Usuario'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: userNotifier.users.length,
                      itemBuilder: (context, index) {
                        final user = userNotifier.users[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                user.username[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.username,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(user.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    context.go('/home/users/${user.id}');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _confirmDelete(context, user.id!);
                                  },
                                ),
                                // Botón para cambiar la contraseña
                                IconButton(
                                  icon: const Icon(Icons.lock_reset,
                                      color: Colors.orange),
                                  onPressed: () {
                                    _showChangePasswordDialog(
                                        context, user.id!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Método para refrescar la lista de usuarios
  void _refreshUsers() async {
    await ref.read(userProvider.notifier).fetchUsers(context);
  }

  // Confirmar la eliminación de un usuario
  void _confirmDelete(BuildContext context, int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(userProvider.notifier)
                    .deleteUser(userId, context);
                Navigator.of(context)
                    .pop(); // Cerrar el diálogo después de eliminar
                _refreshUsers(); // Actualizar los usuarios
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color del botón de eliminar
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar diálogo para cambiar la contraseña
  void _showChangePasswordDialog(BuildContext context, int userId) {
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cambiar Contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Nueva Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newPassword = passwordController.text.trim();
                    if (newPassword.isNotEmpty) {
                      await ref
                          .read(userProvider.notifier)
                          .updatePassword(userId, newPassword, context);
                      Navigator.of(context)
                          .pop(); // Cerrar el diálogo después de cambiar
                    }
                  },
                  child: const Text('Cambiar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
