import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:engage_app/features/clothing/models/clothing_item_model.dart';
import 'package:engage_app/features/clothing/repository/clothing_repository.dart';

part 'clothing_state.dart';

class ClothingCubit extends Cubit<ClothingState> {
  final ClothingRepository _clothingRepository;

  ClothingCubit(this._clothingRepository) : super(const ClothingState());

  /// Busca as peças de roupa do usuário logado
  Future<void> fetchClothing() async {
    log('[ClothingCubit] Buscando roupas...');
    emit(state.copyWith(status: ClothingStatus.loading));
    try {
      final items = await _clothingRepository.fetchMyClothingItems();
      emit(state.copyWith(
        status: ClothingStatus.success,
        items: items,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: ClothingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Adiciona uma nova peça de roupa e atualiza a lista
  Future<void> addClothingItem({
    required String name,
    required String category,
    required File imageFile, // 2. Agora recebe um File em vez de uma String
  }) async {
    try {
      await _clothingRepository.createClothingItem(
        name: name,
        category: category,
        imageFile: imageFile, // 3. Passa o File para o repositório
      );

      // Após criar o item com sucesso, busca a lista atualizada.
      await fetchClothing();
      
    } catch (e) {
      log('[ClothingCubit] Erro ao adicionar item: $e');
      // Relança o erro para que a UI possa saber que a operação falhou.
      throw e;
    }
  }
}