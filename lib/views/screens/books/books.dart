import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/models/books.dart';
import 'package:lib_soma_front/providers/books_provider.dart';
import 'package:lib_soma_front/providers/categoria_provider.dart';

class BookScreen extends ConsumerStatefulWidget {
  const BookScreen({Key? key}) : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends ConsumerState<BookScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryId;
  bool _isGridView =
      false; // Para controlar si estamos en vista de cuadrícula o lista

  @override
  void initState() {
    super.initState();
    // Cargar libros y categorías al entrar a la pantalla
    Future.microtask(() {
      ref.read(bookProvider.notifier).fetchBooks(context);
      ref.read(categoryProvider.notifier).fetchCategories(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookNotifier = ref.watch(bookProvider);
    final categoryNotifier = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Libros'),
        actions: [
          IconButton(
            icon: _isGridView
                ? const Icon(Icons.view_list)
                : const Icon(Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView; // Cambiar entre lista y cuadrícula
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(bookProvider.notifier).fetchBooks(context);
              ref.read(categoryProvider.notifier).fetchCategories(context);
            },
          ),
        ],
      ),
      body: bookNotifier.isLoading || categoryNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por título o autor',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _searchQuery = _searchController.text.trim();
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<int>(
                    hint: const Text('Filtrar por categoría'),
                    value: _selectedCategoryId,
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Sin Filtro'),
                      ),
                      ...categoryNotifier.categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (categoryId) {
                      setState(() {
                        _selectedCategoryId = categoryId;
                      });
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.go('/home/books/new');
                        },
                        child: const Text('Agregar Nuevo Libro'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _selectedCategoryId = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(),
                        child: const Text('Limpiar Filtros'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isGridView
                        ? _buildGridView(bookNotifier, categoryNotifier)
                        : _buildListView(bookNotifier, categoryNotifier),
                  ),
                ],
              ),
            ),
    );
  }

  // Construir la vista de cuadrícula
  Widget _buildGridView(bookNotifier, categoryNotifier) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Número de columnas
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _filteredBooks(bookNotifier.books).length,
      itemBuilder: (context, index) {
        final book = _filteredBooks(bookNotifier.books)[index];
        final category = categoryNotifier.categories.firstWhere(
          (cat) => cat.id == book.categoryId,
        );

        return SizedBox(
          height: 1,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: [
                  Icon(Icons.book,
                      size: 60,
                      color:
                          Theme.of(context).primaryColor), // Icono más pequeño
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold), // Texto más pequeño
                  ),
                  const SizedBox(height: 8),
                  Text('Autor: ${book.author}',
                      style: const TextStyle(fontSize: 12)), // Texto ajustado
                  Text('Categoría: ${category?.name ?? 'Desconocida'}',
                      style: const TextStyle(fontSize: 12)),
                  Text('ISBN: ${book.isbn}',
                      style: const TextStyle(fontSize: 12)),
                  Text('Copias: ${book.copiesAvailable}',
                      style: const TextStyle(fontSize: 12)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue, size: 18),
                        onPressed: () {
                          context.go('/home/books/${book.id}');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 18),
                        onPressed: () {
                          _confirmDelete(context, book.id!, ref);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Construir la vista de lista
  Widget _buildListView(bookNotifier, categoryNotifier) {
    return ListView.builder(
      itemCount: _filteredBooks(bookNotifier.books).length,
      itemBuilder: (context, index) {
        final book = _filteredBooks(bookNotifier.books)[index];
        final category = categoryNotifier.categories.firstWhere(
          (cat) => cat.id == book.categoryId,
        );

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.book,
                    size: 50, color: Theme.of(context).primaryColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Autor: ${book.author}'),
                      Text('Categoría: ${category?.name ?? 'Desconocida'}'),
                      Text('ISBN: ${book.isbn}'),
                      Text('Copias disponibles: ${book.copiesAvailable}'),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        context.go('/home/books/${book.id}');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _confirmDelete(context, book.id!, ref);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Filtrar libros por texto ingresado y categoría seleccionada
  List<Book> _filteredBooks(List<Book> books) {
    return books.where((book) {
      final matchesSearch = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategoryId == null || book.categoryId == _selectedCategoryId;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _confirmDelete(BuildContext context, int bookId, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Libro'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este libro?'),
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
                    .read(bookProvider.notifier)
                    .deleteBook(bookId, context);
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
