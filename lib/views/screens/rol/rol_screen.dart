import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/providers/rol_provider.dart';

class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({Key? key}) : super(key: key);

  @override
  _RoleScreenState createState() => _RoleScreenState();
}

class _RoleScreenState extends ConsumerState<RoleScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(roleProvider.notifier).fetchRoles(context));
  }

  @override
  Widget build(BuildContext context) {
    final roleNotifier = ref.watch(roleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Roles'),
        centerTitle: true,
      ),
      body: roleNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      context.go('/home/roles/new');
                    },
                    child: const Text('Crear Nuevo Rol'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: roleNotifier.roles.length,
                      itemBuilder: (context, index) {
                        final role = roleNotifier.roles[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(role.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                context.go('/home/roles/${role.id}');
                              },
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
}
