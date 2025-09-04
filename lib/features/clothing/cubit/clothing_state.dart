part of 'clothing_cubit.dart';

enum ClothingStatus { initial, loading, success, error }

class ClothingState extends Equatable {
  final ClothingStatus status;
  final List<ClothingItem> items;
  final String? errorMessage;

  const ClothingState({
    this.status = ClothingStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  ClothingState copyWith({
    ClothingStatus? status,
    List<ClothingItem>? items,
    String? errorMessage,
  }) {
    return ClothingState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
