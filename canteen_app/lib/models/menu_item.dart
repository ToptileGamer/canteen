enum FoodCategory { breakfast, lunch, snacks, drinks }

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final FoodCategory category;
  final String imageUrl;
  final bool isAvailable;
  final int preparationTimeMinutes;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isAvailable = true,
    this.preparationTimeMinutes = 10,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    FoodCategory? category,
    String? imageUrl,
    bool? isAvailable,
    int? preparationTimeMinutes,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category.name,
        'imageUrl': imageUrl,
        'isAvailable': isAvailable,
        'preparationTimeMinutes': preparationTimeMinutes,
      };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        category: FoodCategory.values.byName(json['category']),
        imageUrl: json['imageUrl'],
        isAvailable: json['isAvailable'] ?? true,
        preparationTimeMinutes: json['preparationTimeMinutes'] ?? 10,
      );
}
