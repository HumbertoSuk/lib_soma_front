import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/providers/rol_provider.dart';

class RoleFormScreen extends ConsumerStatefulWidget {
  final int? roleId; // Si es nulo, es un nuevo rol; de lo contrario, se edita

  const RoleFormScreen({Key? key, this.roleId}) : super(key: key);

  @override
  _RoleFormScreenState createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends ConsumerState<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    if (widget.roleId != null) {
      _isEditing = true;
      Future.microtask(() async {
        await ref
            .read(roleProvider.notifier)
            .getRoleById(widget.roleId!, context);
        final role = ref.read(roleProvider).selectedRole;
        if (role != null) {
          _nameController.text = role.name;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Método para mostrar el SnackBar con un mensaje
  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final roleNotifier = ref.read(roleProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Rol' : 'Crear Nuevo Rol'),
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del rol'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del rol';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text.trim();

                    try {
                      if (_isEditing) {
                        // Actualizar el rol
                        await roleNotifier.updateRole(
                            widget.roleId!, name, context);
                        _showSnackBar(context, 'Rol actualizado correctamente');
                      } else {
                        // Crear un nuevo rol
                        await roleNotifier.createRole(name, context);
                        _showSnackBar(context, 'Rol creado correctamente');
                      }
                      // Volver a la pantalla de roles
                      context.go('/home/roles');
                    } catch (e) {
                      _showSnackBar(context, 'Error: ${e.toString()}',
                          isError: true);
                    }
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
}
