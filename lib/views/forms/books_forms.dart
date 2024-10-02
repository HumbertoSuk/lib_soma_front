import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/models/books.dart';
import 'package:lib_soma_front/providers/books_provider.dart';
import 'package:lib_soma_front/providers/categoria_provider.dart';

class BookFormScreen extends ConsumerStatefulWidget {
  final int? bookId; // Si es nulo, es un nuevo libro; si no, es para editar

  const BookFormScreen({Key? key, this.bookId}) : super(key: key);

  @override
  _BookFormScreenState createState() => _BookFormScreenState();
}

class _BookFormScreenState extends ConsumerState<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _copiesAvailableController;
  int? _selectedCategoryId;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _isbnController = TextEditingController();
    _copiesAvailableController = TextEditingController();

    if (widget.bookId != null) {
      _isEditing = true;
      Future.microtask(() async {
        await ref
            .read(bookProvider.notifier)
            .getBookById(widget.bookId!, context);
        final book = ref.read(bookProvider).selectedBook;
        if (book != null) {
          _titleController.text = book.title;
          _authorController.text = book.author;
          _isbnController.text = book.isbn;
          _copiesAvailableController.text = book.copiesAvailable.toString();
          _selectedCategoryId = book.categoryId;
        }
      });
    }

    Future.microtask(
        () => ref.read(categoryProvider.notifier).fetchCategories(context));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _copiesAvailableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryNotifier = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Libro' : 'Crear Nuevo Libro'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el autor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(labelText: 'ISBN'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el ISBN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _copiesAvailableController,
                decoration:
                    const InputDecoration(labelText: 'Copias Disponibles'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el número de copias disponibles';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: categoryNotifier.categories
                    .map((category) => DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        ))
                    .toList(),
                onChanged: (categoryId) {
                  setState(() {
                    _selectedCategoryId = categoryId;
                  });
                },
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final book = Book(
                      id: widget.bookId,
                      title: _titleController.text.trim(),
                      author: _authorController.text.trim(),
                      categoryId: _selectedCategoryId!,
                      isbn: _isbnController.text.trim(),
                      copiesAvailable:
                          int.parse(_copiesAvailableController.text.trim()),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    if (_isEditing) {
                      await ref
                          .read(bookProvider.notifier)
                          .updateBook(widget.bookId!, book, context);
                    } else {
                      await ref
                          .read(bookProvider.notifier)
                          .createBook(book, context);
                    }

                    context.go('/home/books');
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
