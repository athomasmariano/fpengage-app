// lib/features/clothing/repository/clothing_repository.dart

import 'dart:developer';
import 'dart:io'; // Importante para usar a classe 'File'
import 'package:dio/dio.dart';
import 'package:engage_app/features/clothing/models/clothing_item_model.dart';

class ClothingRepository {
  final Dio _dio;

  ClothingRepository(this._dio);

  /// Busca todos os itens de roupa do usuário logado.
  Future<List<ClothingItem>> fetchMyClothingItems() async {
    try {
      log('[ClothingRepository] Buscando itens de roupa...');
      final response = await _dio.get('/clothing-items');

      if (response.statusCode == 200 && response.data is List) {
        // Converte a lista de JSONs em uma lista de objetos ClothingItem
        final List<dynamic> jsonData = response.data;
        final clothingItems =
            jsonData.map((item) => ClothingItem.fromJson(item)).toList();
        log('[ClothingRepository] ${clothingItems.length} itens encontrados.');
        return clothingItems;
      } else {
        throw 'Resposta do servidor inválida ao buscar itens de roupa.';
      }
    } on DioException catch (e) {
      log('[ClothingRepository] Erro ao buscar itens: ${e.response?.data}');
      throw 'Não foi possível carregar o guarda-roupa. Tente novamente.';
    } catch (e) {
      log('[ClothingRepository] Erro inesperado ao buscar itens: $e');
      throw 'Ocorreu um erro inesperado.';
    }
  }

  /// **[ATUALIZADO]** Cria um novo item de roupa enviando um arquivo de imagem.
  Future<ClothingItem> createClothingItem({
    required String name,
    required String category,
    required File imageFile, // 1. Agora recebe um arquivo (File)
  }) async {
    try {
      log('[ClothingRepository] Criando novo item com upload de imagem...');

      // 2. Prepara os dados como 'form-data' para o upload
      final formData = FormData.fromMap({
        'name': name,
        'category': category,
        // O Dio converte o arquivo para o formato de upload correto (multipart/form-data)
        // O campo 'image' deve ser o mesmo que o FileInterceptor espera no backend.
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/clothing-items',
        data: formData, // 3. Envia o formData em vez de um JSON simples
      );

      if (response.statusCode == 201 && response.data != null) {
        final newItem = ClothingItem.fromJson(response.data);
        log('[ClothingRepository] Item criado com sucesso: ${newItem.name}');
        return newItem;
      } else {
        throw 'Resposta do servidor inválida ao criar item.';
      }
    } on DioException catch (e) {
      log('[ClothingRepository] Erro ao criar item: ${e.response?.data}');
      throw 'Não foi possível adicionar a peça. Verifique os dados e tente novamente.';
    } catch (e) {
      log('[ClothingRepository] Erro inesperado ao criar item: $e');
      throw 'Ocorreu um erro inesperado.';
    }
  }
}