import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lib_soma_front/providers/books_provider.dart';
import 'package:lib_soma_front/providers/multas_provider.dart';
import 'package:lib_soma_front/providers/prestamos_provider.dart';
import 'package:lib_soma_front/providers/user_provider.dart';

class AdminFinesPage extends ConsumerStatefulWidget {
  const AdminFinesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminFinesPage> createState() => _AdminFinesPageState();
}

class _AdminFinesPageState extends ConsumerState<AdminFinesPage> {
  late Future<void> _fetchFinesFuture;
  String _selectedStatus = 'Todos';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFinesFuture = _fetchFines();
  }

  Future<void> _fetchFines() async {
    await ref.read(fineProvider.notifier).fetchFines(context);
    await ref.read(userProvider.notifier).fetchUsers(context);
    await ref
        .read(loanProvider.notifier)
        .fetchLoans(context); // Fetch loans data
    await ref
        .read(bookProvider.notifier)
        .fetchBooks(context); // Fetch books data
  }

  Future<void> _confirmPayFine(
      BuildContext context, int fineId, int loanId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmación de pago'),
          content: const Text(
              '¿Está seguro de que desea marcar esta multa como pagada? Esto también marcará el préstamo como devuelto.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(loanProvider.notifier).returnLoan(loanId, context);
      await ref.read(fineProvider.notifier).payFine(fineId, context);

      setState(() {
        _fetchFinesFuture = _fetchFines();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final finesAsync = ref.watch(fineProvider);
    final usersAsync = ref.watch(userProvider);
    final loansAsync = ref.watch(loanProvider);
    final booksAsync = ref.watch(bookProvider); // Watch the BookProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Multas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _fetchFinesFuture = _fetchFines();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por usuario',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'Pagada', child: Text('Pagada')),
                    DropdownMenuItem(
                        value: 'Pendiente', child: Text('Pendiente')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? 'Todos';
                    });
                  },
                ),
              ],
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
                final users = usersAsync.users;
                final loans = loansAsync.loans;
                final books = booksAsync.books;

                if (fines.isEmpty) {
                  return const Center(child: Text('No se encontraron multas.'));
                }

                // Apply filters to fines based on user search and paid status
                final filteredFines = fines.where((fine) {
                  final user = users.firstWhere(
                    (u) => u.id == fine.userId,
                  );
                  final matchesUser = user != null &&
                      user.username.toLowerCase().contains(_searchQuery);
                  final matchesStatus = _selectedStatus == 'Todos' ||
                      (_selectedStatus == 'Pagada' && fine.paid) ||
                      (_selectedStatus == 'Pendiente' && !fine.paid);

                  return matchesUser && matchesStatus;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredFines.length,
                  itemBuilder: (context, index) {
                    final fine = filteredFines[index];
                    final user = users.firstWhere(
                      (u) => u.id == fine.userId,
                    );
                    final loan = loans.firstWhere(
                      (l) => l.id == fine.loanId,
                    );
                    final book = books.firstWhere(
                      (b) => b.id == loan.bookId,
                    );

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
                              'Usuario: ${user?.username ?? 'Desconocido'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Libro: ${book?.title ?? 'No disponible'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Descripción: ${fine.description}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (loan != null) // Show loan date if available
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
                            const SizedBox(height: 10),
                            !fine.paid
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                    onPressed: () => _confirmPayFine(
                                        context, fine.id, fine.loanId),
                                    child: const Text(
                                      'Marcar como pagada',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 28,
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
