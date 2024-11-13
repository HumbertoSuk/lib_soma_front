import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el role_id del usuario autenticado
    final roleId = ref.watch(authProvider).roleId;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text(
              'Biblioteca Virtual',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),

          // Inicio
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Inicio'),
            onTap: () {
              context.go('/home');
            },
          ),

          // Divider with padding for spacing
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),

          // Catálogo de Libros
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Catálogo de Libros'),
            onTap: () {
              context.go('/home/catalog');
            },
          ),

          // Mis Reservaciones/Préstamos
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Mis Reservaciones/Préstamos'),
            onTap: () {
              context.go('/home/user-reservaciones/');
            },
          ),

          // Mis Multas
          ListTile(
            leading: const Icon(Icons.money_off),
            title: const Text('Mis Multas'),
            onTap: () {
              context.go('/home/user-multas');
            },
          ),

          // Divider with padding for spacing
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),

          // Opciones solo para administradores (role_id == 1)
          if (roleId == 1) ...[
            // Categorías de Libros
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categorías de Libros'),
              onTap: () {
                context.go('/home/categories');
              },
            ),

            // Libros
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Libros'),
              onTap: () {
                context.go('/home/books');
              },
            ),

            // Roles
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Roles'),
              onTap: () {
                context.go('/home/roles');
              },
            ),

            // Registrar Usuarios
            ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: const Text('Registrar Usuarios'),
              onTap: () {
                context.go('/home/users');
              },
            ),

            // Reservaciones
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('Reservaciones'),
              onTap: () {
                context.go('/home/reservations');
              },
            ),

            // Préstamos
            ListTile(
              leading: const Icon(Icons.assignment_return),
              title: const Text('Préstamos'),
              onTap: () {
                context.go('/home/loans');
              },
            ),

            // Multas
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Multas'),
              onTap: () {
                context.go('/home/fines');
              },
            ),
          ],

          // Final Divider with additional spacing
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 36.0),
            child: Divider(),
          ),
        ],
      ),
    );
  }
}
