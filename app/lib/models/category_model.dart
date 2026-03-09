import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int count;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon = 'category',
    this.count = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'category',
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'icon': icon, 'count': count};
  }

  @override
  List<Object?> get props => [id, name, icon, count];

  // Predefined categories for Kigali City Services
  static List<CategoryModel> get defaultCategories => [
    const CategoryModel(
      id: 'hospital',
      name: 'Hospital',
      icon: 'local_hospital',
    ),
    const CategoryModel(
      id: 'police',
      name: 'Police Station',
      icon: 'local_police',
    ),
    const CategoryModel(id: 'library', name: 'Library', icon: 'local_library'),
    const CategoryModel(
      id: 'restaurant',
      name: 'Restaurant',
      icon: 'restaurant',
    ),
    const CategoryModel(id: 'cafe', name: 'Café', icon: 'local_cafe'),
    const CategoryModel(id: 'park', name: 'Park', icon: 'park'),
    const CategoryModel(
      id: 'tourist_attraction',
      name: 'Tourist Attraction',
      icon: 'attractions',
    ),
    const CategoryModel(
      id: 'utility',
      name: 'Utility Office',
      icon: 'business',
    ),
  ];
}
