import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/models/categorias.dart';
import 'package:lib_soma_front/providers/categoria_provider.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final int?
      categoryId; // Si es nulo, es una nueva categoría; de lo contrario, se edita

  const CategoryFormScreen({Key? key, this.categoryId}) : super(key: key);

  @override
  _CategoryFormScreenState createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    if (widget.categoryId != null) {
      _isEditing = true;
      Future.microtask(() async {
        await ref
            .read(categoryProvider.notifier)
            .getCategoryById(widget.categoryId!, context);
        final category = ref.read(categoryProvider).selectedCategory;
        if (category != null) {
          _nameController.text = category.name;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Categoría' : 'Crear Nueva Categoría'),
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
                decoration:
                    const InputDecoration(labelText: 'Nombre de la Categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final category = Category(
                      id: widget.categoryId, // Para edición
                      name: _nameController.text.trim(),
                    );

                    if (_isEditing) {
                      await ref.read(categoryProvider.notifier).updateCategory(
                          widget.categoryId!, category, context);
                    } else {
                      await ref
                          .read(categoryProvider.notifier)
                          .createCategory(category, context);
                    }

                    context.go('/home/categories');
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
