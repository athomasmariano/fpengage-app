// lib/features/home/view/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guarda-Roupa Virtual'),
      ),
      body: const Center(
        child: Text('Bem-vindo! Aqui ficarão suas roupas.'),
      ),
    );
  }
}