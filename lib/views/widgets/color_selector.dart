import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lib_soma_front/providers/theme_provider.dart';

class ColorSelector extends ConsumerWidget {
  const ColorSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final colorList = ref.read(colorListProvider); // Lista de colores

    return Wrap(
      spacing: 10,
      children: List.generate(
        colorList.length,
        (index) => GestureDetector(
          onTap: () =>
              themeNotifier.changeColorIndex(index), // Cambiar color del tema
          child: CircleAvatar(
            backgroundColor: colorList[index],
            radius: 20,
          ),
        ),
      ),
    );
  }
}
