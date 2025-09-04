import 'dart:developer';
import 'package:engage_app/features/auth/cubit/auth_cubit.dart';
import 'package:engage_app/features/auth/view/login_screen.dart';
import 'package:engage_app/features/clothing/cubit/clothing_cubit.dart';
import 'package:engage_app/features/clothing/models/clothing_item_model.dart';
import 'package:engage_app/features/clothing/view/add_clothing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Versão final e simplificada como StatelessWidget
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guarda-Roupa Virtual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              context.read<AuthCubit>().logoutUser();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ClothingCubit, ClothingState>(
        builder: (context, state) {
          if (state.status == ClothingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ClothingStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ??
                    'Ocorreu um erro ao carregar o guarda-roupa.',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state.status == ClothingStatus.success && state.items.isEmpty) {
            return const Center(
              child: Text('Seu guarda-roupa está vazio. Adicione uma peça!'),
            );
          }
          if (state.status == ClothingStatus.success) {
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ClothingCard(item: item);
              },
            );
          }
          // Estado inicial
          return const Center(child: Text('Bem-vindo! Carregando...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ClothingCubit>(),
                child: const AddClothingScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Um widget para exibir um único item de roupa em um card.
class ClothingCard extends StatelessWidget {
  final ClothingItem item;
  const ClothingCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    log('--- Tentando carregar imagem da URL: ${item.imageUrl}');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  log('--- Erro ao carregar imagem: $error');
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
