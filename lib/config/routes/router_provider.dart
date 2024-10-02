import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/views/forms/books_forms.dart';
import 'package:lib_soma_front/views/forms/categorias_form.dart';
import 'package:lib_soma_front/views/forms/register_form.dart';
import 'package:lib_soma_front/views/forms/role_form.dart';
import 'package:lib_soma_front/views/screens/SplashardScreen.dart';
import 'package:lib_soma_front/views/screens/books/books.dart';
import 'package:lib_soma_front/views/screens/categorias/categorias_screen.dart';
import 'package:lib_soma_front/views/screens/home/home_screen.dart';
import 'package:lib_soma_front/views/screens/login/login_screen.dart';
import 'package:lib_soma_front/views/screens/register/register.dart';
import 'package:lib_soma_front/views/screens/rol/rol_screen.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
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
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authNotifier.isAuthenticated();
      final isLoggingIn = state.matchedLocation == '/';

      // Redirigir al login si no está autenticado
      if (!isAuthenticated && !isLoggingIn) {
        return '/'; // Redirige al login
      }

      // Si está autenticado y trata de acceder al login, redirigir al home
      if (isAuthenticated && isLoggingIn) {
        return '/home'; // Redirige al home
      }

      return null; // Permitir navegación normal
    },
    refreshListenable: ref.watch(authProvider.notifier),
  );
});
