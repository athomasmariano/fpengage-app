// lib/features/auth/cubit/auth_cubit.dart

import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:engage_app/features/auth/repository/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState());

  /// Método para registrar um novo usuário
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Método para fazer o login do usuário
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    log('1. [AuthCubit] Tentando fazer login com o email: $email');
    emit(state.copyWith(status: AuthStatus.loading));

    // try-catch restaurado!
    try {
      await _authRepository.login(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Método para fazer logout (apagar o token)
  Future<void> logoutUser() async {
    await _authRepository.deleteToken();
    // Você pode emitir um estado aqui se a UI precisar reagir ao logout
  }
}
