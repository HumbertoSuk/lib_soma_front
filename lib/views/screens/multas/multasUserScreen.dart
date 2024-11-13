import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lib_soma_front/providers/books_provider.dart';
import 'package:lib_soma_front/providers/multas_provider.dart';
import 'package:lib_soma_front/providers/prestamos_provider.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

class UserFinesPage extends ConsumerStatefulWidget {
  const UserFinesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UserFinesPage> createState() => _UserFinesPageState();
}

class _UserFinesPageState extends ConsumerState<UserFinesPage> {
  late Future<void> _fetchFinesFuture;
  String _selectedStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    _fetchFinesFuture = _fetchUserFines();
  }

  Future<void> _fetchUserFines() async {
    await ref.read(fineProvider.notifier).fetchFines(context);
    await ref.read(loanProvider.notifier).fetchLoans(context);
    await ref.read(bookProvider.notifier).fetchBooks(context);
  }

  @override
  Widget build(BuildContext context) {
    final finesAsync = ref.watch(fineProvider);
    final loansAsync = ref.watch(loanProvider);
    final booksAsync = ref.watch(bookProvider);
    final authAsync = ref.watch(authProvider);

    final currentUserId = authAsync.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Multas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _fetchFinesFuture = _fetchUserFines();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: _selectedStatus,
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Pagada', child: Text('Pagada')),
                DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value ?? 'Todos';
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _fetchFinesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error al cargar las multas'));
                }

                final fines = finesAsync.fines;
                final loans = loansAsync.loans;
                final books = booksAsync.books;

                // Filter fines for the current user only
                final userFines = fines.where((fine) {
                  final isCurrentUserFine = fine.userId == currentUserId;
                  final matchesStatus = _selectedStatus == 'Todos' ||
                      (_selectedStatus == 'Pagada' && fine.paid) ||
                      (_selectedStatus == 'Pendiente' && !fine.paid);
                  return isCurrentUserFine && matchesStatus;
                }).toList();

                if (userFines.isEmpty) {
                  return const Center(
                      child: Text('No tienes multas pendientes.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: userFines.length,
                  itemBuilder: (context, index) {
                    final fine = userFines[index];
                    final loan = loans.firstWhere((l) => l.id == fine.loanId);
                    final book = books.firstWhere((b) => b.id == loan.bookId);

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Multa: \$${fine.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Libro: ${book?.title ?? 'No disponible'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Descripción: ${fine.description}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Fecha de Préstamo: ${DateFormat.yMMMMd().format(loan.loanDate)}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.blue),
                            ),
                            Text(
                              'Fecha de Multa: ${DateFormat.yMMMMd().format(fine.fineDate)}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              'Estado: ${fine.paid ? 'Pagada' : 'Pendiente'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: fine.paid ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
