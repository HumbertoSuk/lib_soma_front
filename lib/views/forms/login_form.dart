import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/utils/validates.dart';
import 'package:lib_soma_front/providers/auth_provider.dart'; // Importar el provider de autenticación

class LoginForm extends ConsumerStatefulWidget with FormValidation {
  LoginForm({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm>
    with SingleTickerProviderStateMixin {
  final _passwordVisible = ValueNotifier<bool>(false);
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Configurar la animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeInOut));

    // Iniciar la animación
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width:
                MediaQuery.of(context).size.width > 600 ? 400 : double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_library_outlined,
                    size: 60), // Icono biblioteca
                const SizedBox(height: 20),
                const Text(
                  'Biblioteca Virtual',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Campo de Usuario con ícono y animación
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    labelText: 'Usuario',
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Contraseña con botón de visibilidad
                ValueListenableBuilder<bool>(
                  valueListenable: _passwordVisible,
                  builder: (_, bool isVisible, __) {
                    return TextField(
                      controller: _passwordController,
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: 'Contraseña',
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => _passwordVisible.value = !isVisible,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Botón de Iniciar Sesión con animación de color
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: () async {
                      final username = _usernameController.text.trim();
                      final password = _passwordController.text.trim();

                      if (username.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuario y contraseña requeridos'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        // Llamar al método de autenticación
                        await ref
                            .read(authProvider.notifier)
                            .login(username, password);
                        // Si es exitoso, redirigir a /home
                        context.go('/home');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(fontSize: 18),
                    ),
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
