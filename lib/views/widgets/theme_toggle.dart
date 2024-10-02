import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lib_soma_front/providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return IconButton(
      icon: const Icon(Icons.brightness_6),
      onPressed: () =>
          themeNotifier.toggleDarkMode(), // Cambiar modo oscuro/claro
    );
  }
}
