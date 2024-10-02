import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/models/user.dart';
import 'package:lib_soma_front/providers/rol_provider.dart';
import 'package:lib_soma_front/providers/user_provider.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  final int?
      userId; // Si es nulo, es un nuevo usuario; de lo contrario, se edita

  const UserFormScreen({Key? key, this.userId}) : super(key: key);

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  TextEditingController? _passwordController;
  int? _selectedRoleId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();

    if (widget.userId != null) {
      _isEditing = true;
      Future.microtask(() async {
        await ref
            .read(userProvider.notifier)
            .getUserById(widget.userId!, context);
        final user = ref.read(userProvider).selectedUser;
        if (user != null) {
          _usernameController.text = user.username;
          _emailController.text = user.email;
          _selectedRoleId = user.roleId;
        }
      });
    } else {
      _passwordController =
          TextEditingController(); // Solo crear si no es edición
    }

    Future.microtask(() => ref.read(roleProvider.notifier).fetchRoles(context));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleNotifier = ref.watch(roleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Usuario' : 'Crear Nuevo Usuario'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el correo electrónico';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (!_isEditing) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],
              DropdownButtonFormField<int>(
                value: _selectedRoleId,
                items: roleNotifier.roles
                    .map((role) => DropdownMenuItem<int>(
                          value: role.id,
                          child: Text(role.name),
                        ))
                    .toList(),
                onChanged: (roleId) {
                  setState(() {
                    _selectedRoleId = roleId;
                  });
                },
                decoration: const InputDecoration(labelText: 'Rol'),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione un rol';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user = UserModel(
                      id: widget.userId,
                      username: _usernameController.text.trim(),
                      email: _emailController.text.trim(),
                      password:
                          _isEditing ? '' : _passwordController?.text.trim(),
                      roleId: _selectedRoleId!,
                    );

                    if (_isEditing) {
                      await ref
                          .read(userProvider.notifier)
                          .updateUser(widget.userId!, user, context);
                    } else {
                      await ref
                          .read(userProvider.notifier)
                          .createUser(user, context);
                    }

                    _refreshUsers(); // Refrescar lista de usuarios tras crear o editar
                    context.go('/home/users');
                  }
                },
                child: Text(_isEditing ? 'Actualizar' : 'Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Refrescar la lista de usuarios después de crear o actualizar
  void _refreshUsers() async {
    await ref.read(userProvider.notifier).fetchUsers(context);
  }
}
