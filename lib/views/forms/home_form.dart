import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lib_soma_front/providers/auth_provider.dart';
import 'package:lib_soma_front/providers/theme_provider.dart'; // Importar el provider del tema
import 'package:lib_soma_front/views/widgets/menu.dart';

class HomeForm extends ConsumerWidget {
  const HomeForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode =
        ref.watch(themeNotifierProvider).isDarkMode; // Observar el tema oscuro

    final List<String> imageList = [
      'https://i0.wp.com/darkhearttravel.com/wp-content/uploads/2016/04/Queens-College-Old-Library-2.jpg?resize=720%2C480&ssl=1',
      'https://img.freepik.com/premium-photo/vintage-library-with-old-books-background_407474-10015.jpg',
      'https://images.stockcake.com/public/d/1/6/d167b7a5-fe80-4ddc-b4b2-fee124188d1f_large/vintage-library-interior-stockcake.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/');
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(), // Agregar el Drawer personalizado
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Bienvenido a la Biblioteca Virtual Soma',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            iconSize: 40,
            onPressed: () {
              // Alternar entre tema oscuro y claro
              ref.read(themeNotifierProvider.notifier).toggleDarkMode();
            },
          ),
          const Text('Cambiar Tema'),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CarouselSlider.builder(
                itemCount: imageList.length,
                itemBuilder: (context, index, realIndex) {
                  final imageUrl = imageList[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FadeInImage(
                      placeholder: const AssetImage(
                          'assets/loading.gif'), // Puedes cambiar esto por una imagen de carga
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.book,
                            color: Colors.grey,
                            size: 50,
                          ),
                        );
                      },
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.scaleDown,
                      height: 250, // Altura fija
                      width: double.infinity, // Para ocupar el ancho completo
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 250, // Ajuste de la altura
                  autoPlay: true,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  viewportFraction:
                      0.85, // Ajuste de la fracción de la vista para que la imagen central se destaque
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // Espacio al final
        ],
      ),
    );
  }
}
