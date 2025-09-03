// lib/features/auth/repository/auth_repository.dart

import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  // Configuração centralizada do nosso cliente HTTP (Dio).
  // É uma boa prática definir a URL base aqui.
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          'http://10.0.2.2:3000', // Endereço correto para o emulador Android
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  // Instância para o armazenamento seguro de dados.
  final _storage = const FlutterSecureStorage();

  /// Método para registrar um novo usuário
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/users',
        data: {'name': name, 'email': email, 'password': password},
      );
    } on DioException catch (e) {
      // Captura erros específicos da API (4xx, 5xx), conexão, etc.
      log(
        'Erro no registro (DioException): Status ${e.response?.statusCode}, Data: ${e.response?.data}',
      );
      final errorMessage =
          e.response?.data['message']?.toString() ??
          'Erro ao registrar usuário.';
      throw errorMessage;
    } catch (e) {
      // Captura qualquer outro erro inesperado.
      log('Erro inesperado no registro: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  /// Método para fazer login e salvar o token JWT
  Future<void> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // Se o código chegou aqui, a resposta teve sucesso (status 2xx).
      log('Resposta da API recebida com sucesso: ${response.data}');

      // Validação defensiva: garante que a resposta não é nula e contém o token.
      if (response.data != null && response.data['access_token'] is String) {
        await _storage.write(
          key: 'jwt_token',
          value: response.data['access_token'],
        );
        log('Token salvo com sucesso!');
      } else {
        // Isso aconteceria se o backend retornasse 200 OK mas com um corpo inválido.
        throw 'Resposta do servidor inválida.';
      }
    } on DioException catch (e) {
      // Este é o bloco principal para erros de login (ex: senha errada, status 401).
      log(
        'ERRO DE API! [DioException]: Status ${e.response?.statusCode}, Data: ${e.response?.data}',
      );
      // Tenta extrair a mensagem de erro específica do NestJS.
      final errorMessage =
          e.response?.data['message']?.toString() ??
          'Credenciais inválidas ou erro no servidor.';
      throw errorMessage;
    } catch (e) {
      // Qualquer outro erro inesperado (ex: erro de parsing do JSON).
      log('ERRO INESPERADO! Tipo: ${e.runtimeType}, Erro: $e');
      throw 'Ocorreu um erro inesperado ao processar a resposta.';
    }
  }

  /// Método para ler o token do armazenamento seguro
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  /// Método para apagar o token do armazenamento (para logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.deleteAll(); // Garante que tudo seja limpo
  }
}
