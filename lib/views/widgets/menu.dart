import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías de libros'),
            onTap: () {
              context.go('/home/categories');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Libros'),
            onTap: () {
              context.go('/home/books');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Roles'),
            onTap: () {
              context.go('/home/roles');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Registrar usuarios'),
            onTap: () {
              context.go('/home/users');
            },
          ),
        ],
      ),
    );
  }
}
