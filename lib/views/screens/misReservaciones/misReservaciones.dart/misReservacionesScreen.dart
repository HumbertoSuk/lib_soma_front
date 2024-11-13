import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lib_soma_front/providers/prestamos_provider.dart';
import 'package:lib_soma_front/providers/reservaciones_provider.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';
import 'package:lib_soma_front/providers/books_provider.dart';

class UserReservationsAndLoansPage extends ConsumerWidget {
  const UserReservationsAndLoansPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationNotifier = ref.read(reservationProvider.notifier);
    final loanNotifier = ref.read(loanProvider.notifier);
    final bookNotifier = ref.read(bookProvider.notifier);
    final userId = ref.watch(authProvider).userId;

    Future<void> fetchUserReservationsAndLoans() async {
      if (userId != null) {
        await reservationNotifier.fetchReservations(context);
        await loanNotifier.fetchLoans(context);
        await bookNotifier.fetchBooks(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener el ID del usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    final DateFormat dateFormat = DateFormat('dd/MM/yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservaciones / Préstamos'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: fetchUserReservationsAndLoans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }

          final books = ref.watch(bookProvider).books;
          final reservations = ref
              .watch(reservationProvider)
              .reservations
              .where((r) => r.user == userId)
              .toList();
          final loans = ref
              .watch(loanProvider)
              .loans
              .where((l) => l.userId == userId)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Loans Column
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Préstamos Activos',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              loans.isEmpty
                                  ? const Text('No tienes préstamos activos.')
                                  : Column(
                                      children: loans.map((loan) {
                                        final book = books.firstWhere(
                                          (b) => b.id == loan.bookId,
                                        );
                                        return book != null
                                            ? Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: ListTile(
                                                  title: Text(book.title),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Autor: ${book.author}'),
                                                      Text(
                                                          'Fecha de Préstamo: ${dateFormat.format(loan.loanDate)}'),
                                                    ],
                                                  ),
                                                  trailing: loan.returned
                                                      ? const Text(
                                                          'Devuelto',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue),
                                                        )
                                                      : const Text(
                                                          'Pendiente',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .orange),
                                                        ),
                                                ),
                                              )
                                            : Container();
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Reservations Column
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reservaciones Activas',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              reservations.isEmpty
                                  ? const Text(
                                      'No tienes reservaciones activas.')
                                  : Column(
                                      children: reservations.map((reservation) {
                                        final book = books.firstWhere(
                                          (b) => b.id == reservation.book,
                                        );
                                        return book != null
                                            ? Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: ListTile(
                                                  title: Text(book.title),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Autor: ${book.author}'),
                                                      Text(
                                                          'Fecha de Reservación: ${dateFormat.format(reservation.reservationDate)}'),
                                                    ],
                                                  ),
                                                  trailing: reservation.active
                                                      ? const Text(
                                                          'Activo',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        )
                                                      : const Text(
                                                          'Inactivo',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                ),
                                              )
                                            : Container();
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
