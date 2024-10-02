import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lib_soma_front/views/forms/login_form.dart';
import 'package:lib_soma_front/views/widgets/color_selector.dart';
import 'package:lib_soma_front/views/widgets/theme_toggle.dart';

class LoginView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          ThemeToggleButton(), // Botón modular para cambiar tema
        ],
      ),
      body: Padding(
        // Elimina `const` aquí para permitir que LoginForm funcione correctamente
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoginForm(),
            const SizedBox(height: 24),
            const Text('Selecciona el color principal:'),
            const SizedBox(height: 16),
            const ColorSelector(), // Selector de color modular
          ],
        ),
      ),
    );
  }
}
