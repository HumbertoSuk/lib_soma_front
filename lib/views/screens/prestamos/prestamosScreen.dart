import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lib_soma_front/providers/prestamos_provider.dart';
import 'package:lib_soma_front/providers/books_provider.dart';
import 'package:lib_soma_front/providers/user_provider.dart';

class AdminLoansPage extends ConsumerStatefulWidget {
  const AdminLoansPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminLoansPage> createState() => _AdminLoansPageState();
}

class _AdminLoansPageState extends ConsumerState<AdminLoansPage> {
  late Future<void> _fetchDataFuture;
  String _searchQuery = '';
  String _statusFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchLoansBooksAndUsers();
  }

  Future<void> _fetchLoansBooksAndUsers() async {
    await ref.read(loanProvider.notifier).fetchLoans(context);
    await ref.read(bookProvider.notifier).fetchBooks(context);
    await ref.read(userProvider.notifier).fetchUsers(context);
  }

  Future<void> _confirmReturnLoan(BuildContext context, int loanId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text(
              '¿Está seguro de que desea marcar este préstamo como devuelto?'),
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
      setState(() {
        _fetchDataFuture = _fetchLoansBooksAndUsers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(loanProvider);
    final booksAsync = ref.watch(bookProvider);
    final usersAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Préstamos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por título o usuario',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _statusFilter,
              items: ['Todos', 'Pendiente', 'Devuelto']
                  .map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _statusFilter = value ?? 'Todos';
                });
              },
              isExpanded: true,
              hint: const Text('Filtrar por estado'),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _fetchDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar datos'));
                }

                final loans = loansAsync.loans;
                final books = booksAsync.books;
                final users = usersAsync.users;

                if (loans.isEmpty) {
                  return const Center(
                      child: Text('No se encontraron préstamos.'));
                }

                final filteredLoans = loans.where((loan) {
                  final book = books.firstWhere((b) => b.id == loan.bookId);
                  final user = users.firstWhere((u) => u.id == loan.userId);

                  final matchesSearch = _searchQuery.isEmpty ||
                      (book != null &&
                          book.title.toLowerCase().contains(_searchQuery)) ||
                      (user != null &&
                          user.username.toLowerCase().contains(_searchQuery));

                  final matchesStatus = _statusFilter == 'Todos' ||
                      (_statusFilter == 'Pendiente' && !loan.returned) ||
                      (_statusFilter == 'Devuelto' && loan.returned);

                  return matchesSearch && matchesStatus;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredLoans.length,
                  itemBuilder: (context, index) {
                    final loan = filteredLoans[index];
                    final book = books.firstWhere((b) => b.id == loan.bookId);
                    final user = users.firstWhere((u) => u.id == loan.userId);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                            book != null ? book.title : 'Libro desconocido'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Usuario: ${user != null ? user.username : 'Desconocido'}'),
                            Text(
                                'Correo: ${user != null ? user.email : 'No disponible'}'),
                            Text(
                              'Fecha de Préstamo: ${DateFormat.yMMMMd().add_jm().format(loan.loanDate.toLocal())}',
                            ),
                            Text(
                                'Estado: ${loan.returned ? 'Devuelto' : 'Pendiente'}'),
                            if (book != null) Text('Autor: ${book.author}'),
                          ],
                        ),
                        trailing: !loan.returned
                            ? ElevatedButton(
                                onPressed: () =>
                                    _confirmReturnLoan(context, loan.id),
                                child: const Text('Marcar como devuelto'),
                              )
                            : const Icon(Icons.check, color: Colors.green),
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
