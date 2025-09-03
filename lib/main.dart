// lib/main.dart

import 'package:engage_app/bloc_observer.dart';
import 'package:engage_app/core/api/api_client.dart';
import 'package:engage_app/features/auth/repository/auth_repository.dart';
// 1. Importe o novo repositório
import 'package:engage_app/features/clothing/repository/clothing_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:engage_app/features/auth/cubit/auth_cubit.dart';
import 'package:engage_app/features/auth/view/login_screen.dart';

void main() {
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    // 2. Troque o RepositoryProvider por um MultiRepositoryProvider
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(apiClient.dio),
        ),
        // 3. Adicione o novo ClothingRepository
        RepositoryProvider(
          create: (context) => ClothingRepository(apiClient.dio),
        ),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(
          context.read<AuthRepository>(),
        ),
        child: MaterialApp(
          title: 'Engage App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const LoginScreen(),
        ),
      ),
    );
  }
}