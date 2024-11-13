import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lib_soma_front/models/books.dart';
import 'package:lib_soma_front/providers/books_provider.dart';
import 'package:lib_soma_front/providers/prestamos_provider.dart';
import 'package:lib_soma_front/providers/reservaciones_provider.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

class BookReservePage extends ConsumerWidget {
  final int bookId;

  const BookReservePage({Key? key, required this.bookId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookNotifier = ref.watch(bookProvider);
    final book = bookNotifier.books.firstWhere((b) => b.id == bookId);
    final reservationNotifier = ref.read(reservationProvider.notifier);
    final loanNotifier = ref.read(loanProvider.notifier);
    final userId = ref.watch(authProvider).userId;

    // Refetch book data after making a reservation or loan
    Future<void> refreshBookData() async {
      await ref.read(bookProvider.notifier).fetchBooks(context);
    }

    // Confirmation dialog
    Future<void> showConfirmationDialog(
        String action, VoidCallback onConfirm) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmación de $action'),
            content: Text('¿Estás seguro de que deseas $action este libro?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
    }

    // Handle Reserve or Borrow action
    Future<void> reserveOrBorrowBook(String action) async {
      if (userId != null) {
        if (action == 'Reservar') {
          await reservationNotifier.createReservation(bookId, context);
        } else if (action == 'Préstamo') {
          await loanNotifier.createLoan(bookId, context);
        }
        await refreshBookData(); // Refresh book data after action
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener el ID del usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar / Préstamo'),
        centerTitle: true,
      ),
      body: book == null
          ? const Center(child: Text('Libro no encontrado'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Image
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://art.pixilart.com/8b694d265d632ab.png',
                            height: 200,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Book Title
                      Center(
                        child: Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Book Author
                      Center(
                        child: Text(
                          'Autor: ${book.author}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Additional Information
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text(
                        'ISBN: ${book.isbn}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Disponibles: ${book.copiesAvailable}',
                        style: TextStyle(
                          fontSize: 14,
                          color: book.copiesAvailable > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Reserve / Borrow Buttons with confirmation
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Reserve Button
                            ElevatedButton(
                              onPressed: book.copiesAvailable > 0
                                  ? () => showConfirmationDialog(
                                        'reserva',
                                        () => reserveOrBorrowBook('Reservar'),
                                      )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Reservar'),
                            ),
                            const SizedBox(width: 20),
                            // Borrow Button
                            ElevatedButton(
                              onPressed: book.copiesAvailable > 0
                                  ? () => showConfirmationDialog(
                                        'préstamo',
                                        () => reserveOrBorrowBook('Préstamo'),
                                      )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Préstamo'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
