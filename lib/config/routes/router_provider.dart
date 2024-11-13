import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/views/forms/books_forms.dart';
import 'package:lib_soma_front/views/forms/categorias_form.dart';
import 'package:lib_soma_front/views/forms/register_form.dart';
import 'package:lib_soma_front/views/forms/role_form.dart';
import 'package:lib_soma_front/views/screens/CatalogoBooks/bookReserveScreen.dart';
import 'package:lib_soma_front/views/screens/CatalogoBooks/catalogBookScreen.dart';
import 'package:lib_soma_front/views/screens/SplashardScreen.dart';
import 'package:lib_soma_front/views/screens/books/books.dart';
import 'package:lib_soma_front/views/screens/categorias/categorias_screen.dart';
import 'package:lib_soma_front/views/screens/home/home_screen.dart';
import 'package:lib_soma_front/views/screens/login/login_screen.dart';
import 'package:lib_soma_front/views/screens/misReservaciones/misReservaciones.dart/misReservacionesScreen.dart';
import 'package:lib_soma_front/views/screens/multas/multasScreen.dart';
import 'package:lib_soma_front/views/screens/multas/multasUserScreen.dart';
import 'package:lib_soma_front/views/screens/prestamos/prestamosScreen.dart';
import 'package:lib_soma_front/views/screens/register/register.dart';
import 'package:lib_soma_front/views/screens/reservaciones/reservacionesScreen.dart';
import 'package:lib_soma_front/views/screens/rol/rol_screen.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => LoginView(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeView(),
        routes: [
          GoRoute(
            path: 'catalog',
            name: 'book-catalog',
            builder: (context, state) => const BookCatalogPage(),
            routes: [
              GoRoute(
                path: 'reserve/:bookId',
                name: 'book-reserve',
                builder: (context, state) {
                  final bookId = int.parse(state.pathParameters['bookId']!);
                  return BookReservePage(bookId: bookId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'user-reservaciones',
            name: 'user-reservaciones',
            builder: (context, state) => const UserReservationsAndLoansPage(),
          ),
          GoRoute(
            path: 'user-multas',
            name: 'user-multas',
            builder: (context, state) =>
                const UserFinesPage(), // User-specific fines view screen
          ),
          // Admin-only routes
          GoRoute(
            path: 'roles',
            name: 'roles',
            builder: (context, state) => const RoleScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'role-new',
                builder: (context, state) => const RoleFormScreen(),
              ),
              GoRoute(
                path: ':roleId',
                name: 'role-edit',
                builder: (context, state) {
                  final roleId = int.parse(state.pathParameters['roleId']!);
                  return RoleFormScreen(roleId: roleId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'users',
            name: 'users',
            builder: (context, state) => const UserScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'user-new',
                builder: (context, state) => const UserFormScreen(),
              ),
              GoRoute(
                path: ':userId',
                name: 'user-edit',
                builder: (context, state) {
                  final userId = int.parse(state.pathParameters['userId']!);
                  return UserFormScreen(userId: userId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'categories',
            name: 'categories',
            builder: (context, state) => const CategoryScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'category-new',
                builder: (context, state) => const CategoryFormScreen(),
              ),
              GoRoute(
                path: ':categoryId',
                name: 'category-edit',
                builder: (context, state) {
                  final categoryId =
                      int.parse(state.pathParameters['categoryId']!);
                  return CategoryFormScreen(categoryId: categoryId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'books',
            name: 'books',
            builder: (context, state) => const BookScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'book-new',
                builder: (context, state) => const BookFormScreen(),
              ),
              GoRoute(
                path: ':bookId',
                name: 'book-edit',
                builder: (context, state) {
                  final bookId = int.parse(state.pathParameters['bookId']!);
                  return BookFormScreen(bookId: bookId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'reservations',
            name: 'reservations',
            builder: (context, state) => const AdminReservationsPage(),
          ),
          GoRoute(
            path: 'loans',
            name: 'loans',
            builder: (context, state) => const AdminLoansPage(),
          ),
          GoRoute(
            path: 'fines',
            name: 'fines',
            builder: (context, state) =>
                const AdminFinesPage(), // Admin fines management screen
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authNotifier.isAuthenticated();
      final isAdmin = authNotifier.roleId == 1; // Verificar si es administrador
      final isLoggingIn = state.matchedLocation == '/';

      // Redirect to login if not authenticated
      if (!isAuthenticated && !isLoggingIn) {
        return '/';
      }

      // If authenticated and trying to access login, redirect to home
      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      // Restrict admin-only routes if user is not an admin
      if (state.matchedLocation.contains('/home/') &&
          !isAdmin &&
          state.matchedLocation.contains(RegExp(
              r'(roles|users|categories|books|reservations|loans|fines)'))) {
        return '/home'; // Redirect non-admins trying to access admin routes
      }

      return null;
    },
    refreshListenable: ref.watch(authProvider.notifier),
  );
});
