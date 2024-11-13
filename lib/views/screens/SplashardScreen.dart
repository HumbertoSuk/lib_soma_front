import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(const Duration(seconds: 2), () {
      final authNotifier = ref.read(authProvider.notifier);
      if (authNotifier.isAuthenticated()) {
        context.go('/home'); // Navigate to home if authenticated
      } else {
        context.go('/'); // Navigate to login if not authenticated
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
