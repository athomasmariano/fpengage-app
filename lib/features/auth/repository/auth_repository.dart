import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  // 1. A variável _dio agora é final, mas não é inicializada aqui.
  final Dio _dio;

  // Instância para o armazenamento seguro de dados.
  final _storage = const FlutterSecureStorage();

  // 2. O construtor agora exige que uma instância do Dio seja passada.
  AuthRepository(this._dio);

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
      log(
        'Erro no registro (DioException): Status ${e.response?.statusCode}, Data: ${e.response?.data}',
      );
      final errorMessage =
          e.response?.data['message']?.toString() ??
          'Erro ao registrar usuário.';
      throw errorMessage;
    } catch (e) {
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

      log('Resposta da API recebida com sucesso: ${response.data}');

      if (response.data != null && response.data['access_token'] is String) {
        await _storage.write(
          key: 'jwt_token',
          value: response.data['access_token'],
        );
        log('Token salvo com sucesso!');
      } else {
        throw 'Resposta do servidor inválida.';
      }
    } on DioException catch (e) {
      log(
        'ERRO DE API! [DioException]: Status ${e.response?.statusCode}, Data: ${e.response?.data}',
      );
      final errorMessage =
          e.response?.data['message']?.toString() ??
          'Credenciais inválidas ou erro no servidor.';
      throw errorMessage;
    } catch (e) {
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
