// lib/main.dart
import 'package:engage_app/bloc_observer.dart';
import 'package:engage_app/features/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:engage_app/features/auth/cubit/auth_cubit.dart';
import 'package:engage_app/features/auth/view/login_screen.dart';

void main() {
  // 1. Configure o BlocObserver primeiro
  Bloc.observer = AppBlocObserver(); 

  // 2. Chame runApp uma única vez para iniciar a aplicação
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Disponibiliza o Repository e o Cubit para toda a árvore de widgets abaixo
    return RepositoryProvider(
      create: (context) => AuthRepository(),
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