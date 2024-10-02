import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lib_soma_front/config/routes/router_provider.dart';
import 'providers/theme_provider.dart'; // Importa el provider del tema

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeNotifierProvider); // Obtiene el tema actual
    final router =
        ref.watch(goRouterProvider); // Aquí usamos el goRouterProvider

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: appTheme.getTheme(), // Aplica el tema dinámico
      routerConfig: router, // Usa el GoRouter obtenido del provider
    );
  }
}
