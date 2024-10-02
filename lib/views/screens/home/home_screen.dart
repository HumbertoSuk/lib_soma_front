import 'package:flutter/material.dart';
import 'package:lib_soma_front/views/forms/home_form.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca Virtual'),
        centerTitle: true,
      ),
      body: const HomeForm(),
    );
  }
}
