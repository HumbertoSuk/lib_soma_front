import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/providers/categoria_provider.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar las categorías automáticamente cuando se inicializa la pantalla
    Future.microtask(
        () => ref.read(categoryProvider.notifier).fetchCategories(context));
  }

  @override
  Widget build(BuildContext context) {
    final categoryNotifier = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías de Libros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(categoryProvider.notifier).fetchCategories(context),
          ),
        ],
      ),
      body: categoryNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.go(
                          '/home/categories/new'); // Navegar a crear nueva categoría
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 20.0,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Crear Nueva Categoría'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categoryNotifier.categories.length,
                      itemBuilder: (context, index) {
                        final category = categoryNotifier.categories[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.category,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    context
                                        .go('/home/categories/${category.id}');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _confirmDelete(context, category.id!, ref);
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

  void _confirmDelete(BuildContext context, int categoryId, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Categoría'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar esta categoría?'),
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
                    .read(categoryProvider.notifier)
                    .deleteCategory(categoryId, context);
                Navigator.of(context)
                    .pop(); // Cerrar el diálogo después de eliminar
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
