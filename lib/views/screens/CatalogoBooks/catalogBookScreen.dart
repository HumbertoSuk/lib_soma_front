import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/models/books.dart';
import 'package:lib_soma_front/providers/books_provider.dart';
import 'package:lib_soma_front/providers/categoria_provider.dart';

class BookCatalogPage extends ConsumerStatefulWidget {
  const BookCatalogPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BookCatalogPage> createState() => _BookCatalogPageState();
}

class _BookCatalogPageState extends ConsumerState<BookCatalogPage> {
  String _searchQuery = '';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    ref.read(bookProvider).fetchBooks(context);
    ref.read(categoryProvider).fetchCategories(context);
  }

  @override
  Widget build(BuildContext context) {
    final bookNotifier = ref.watch(bookProvider);
    final categoryNotifier = ref.watch(categoryProvider);

    final List<Book> filteredBooks = bookNotifier.books.where((book) {
      final matchesQuery =
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategoryId == null || book.categoryId == _selectedCategoryId;
      return matchesQuery && matchesCategory && book.copiesAvailable > 0;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Libros'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildCategoryDropdown(categoryNotifier),
            const SizedBox(height: 12),
            Expanded(
              child: bookNotifier.isLoading || categoryNotifier.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredBooks.isNotEmpty
                      ? _buildBookGrid(filteredBooks)
                      : const Center(
                          child: Text(
                            'No se encontraron libros disponibles',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Buscar libros',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
    );
  }

  Widget _buildCategoryDropdown(CategoryNotifier categoryNotifier) {
    return DropdownButton<int?>(
      value: _selectedCategoryId,
      hint: const Text('Filtrar por categoría'),
      isExpanded: true,
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Todas las categorías'),
        ),
        ...categoryNotifier.categories.map((category) {
          return DropdownMenuItem(
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
    );
  }

  Widget _buildBookGrid(List<Book> books) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookCard(book);
      },
    );
  }

  Widget _buildBookCard(Book book) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              color: Colors.grey[200],
              image: const DecorationImage(
                image: NetworkImage(
                    'https://art.pixilart.com/8b694d265d632ab.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Autor: ${book.author}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Disponibles: ${book.copiesAvailable}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/home/catalog/reserve/${book.id}');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text('Reservar/Préstamo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
