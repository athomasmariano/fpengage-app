import 'package:equatable/equatable.dart';

class ClothingItem extends Equatable {
  final int id;
  final String name;
  final String category;
  final String imageUrl;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
  });

  // Construtor de fábrica para criar um ClothingItem a partir de um JSON (mapa)
  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      imageUrl: json['imageUrl'],
    );
  }

  @override
  List<Object?> get props => [id, name, category, imageUrl];
}