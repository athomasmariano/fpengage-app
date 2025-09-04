import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Classe que gerencia nosso cliente Dio e adiciona o interceptor de autenticação.
class ApiClient {
  final Dio dio;
  final _storage = const FlutterSecureStorage();

  ApiClient() : dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  )) {
    // Adiciona o interceptor ao Dio
    dio.interceptors.add(AuthInterceptor(_storage));
  }
}

// O Interceptor que adiciona o token a cada requisição
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  AuthInterceptor(this.storage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Pega o token do armazenamento seguro
    final token = await storage.read(key: 'jwt_token');

    // Se o token existir, o adiciona no cabeçalho 'Authorization'
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continua com a requisição
    return super.onRequest(options, handler);
  }
}