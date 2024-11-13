import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lib_soma_front/providers/reservaciones_provider.dart';
import 'package:lib_soma_front/providers/books_provider.dart';
import 'package:lib_soma_front/providers/user_provider.dart';
import 'package:intl/intl.dart';

class AdminReservationsPage extends ConsumerStatefulWidget {
  const AdminReservationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminReservationsPage> createState() =>
      _AdminReservationsPageState();
}

class _AdminReservationsPageState extends ConsumerState<AdminReservationsPage> {
  late Future<void> _fetchDataFuture;
  String _searchQuery = '';
  String _statusFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchReservationsBooksAndUsers();
  }

  Future<void> _fetchReservationsBooksAndUsers() async {
    await ref.read(reservationProvider.notifier).fetchReservations(context);
    await ref.read(bookProvider.notifier).fetchBooks(context);
    await ref.read(userProvider.notifier).fetchUsers(context);
  }

  Future<void> _confirmFulfillReservation(
      BuildContext context, int reservationId) async {
    // Mostrar diálogo de confirmación
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text(
              '¿Está seguro de que desea marcar esta reservación como cumplida?'),
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
      // Si el usuario confirma, marcar la reservación como cumplida
      await ref
          .read(reservationProvider.notifier)
          .fulfillReservation(reservationId, context);
      setState(() {
        _fetchDataFuture = _fetchReservationsBooksAndUsers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(reservationProvider);
    final booksAsync = ref.watch(bookProvider);
    final usersAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservaciones Administrativas'),
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
              items: ['Todos', 'Pendiente', 'Entregada']
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

                final reservations = reservationsAsync.reservations;
                final books = booksAsync.books;
                final users = usersAsync.users;

                if (reservations.isEmpty) {
                  return const Center(
                      child: Text('No se encontraron reservaciones.'));
                }

                final filteredReservations = reservations.where((reservation) {
                  final book = books.firstWhere(
                    (b) => b.id == reservation.book,
                  );
                  final user = users.firstWhere(
                    (u) => u.id == reservation.user,
                  );

                  final matchesSearch = _searchQuery.isEmpty ||
                      (book != null &&
                          book.title.toLowerCase().contains(_searchQuery)) ||
                      (user != null &&
                          user.username.toLowerCase().contains(_searchQuery));

                  final matchesStatus = _statusFilter == 'Todos' ||
                      (_statusFilter == 'Pendiente' && reservation.active) ||
                      (_statusFilter == 'Entregada' && !reservation.active);

                  return matchesSearch && matchesStatus;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredReservations.length,
                  itemBuilder: (context, index) {
                    final reservation = filteredReservations[index];
                    final book = books.firstWhere(
                      (b) => b.id == reservation.book,
                    );
                    final user = users.firstWhere(
                      (u) => u.id == reservation.user,
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                            book != null ? book.title : 'Libro desconocido'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Usuario: ${user?.username ?? 'Desconocido'}'),
                            Text('Correo: ${user?.email ?? 'No disponible'}'),
                            Text(
                              'Fecha de Reservación: ${DateFormat.yMMMMd().add_jm().format(reservation.reservationDate.toLocal())}',
                            ),
                            Text(
                                'Estado: ${reservation.active ? 'Activa' : 'Cumplida'}'),
                            if (book != null) Text('Autor: ${book.author}'),
                          ],
                        ),
                        trailing: reservation.active
                            ? ElevatedButton(
                                onPressed: () => _confirmFulfillReservation(
                                    context, reservation.id),
                                child: const Text('Marcar como cumplida'),
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
