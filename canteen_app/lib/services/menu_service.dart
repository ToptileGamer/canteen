import '../config/app_config.dart';
import '../models/menu_item.dart';

class MenuService {
  final List<MenuItem> _menuItems = [];

  List<MenuItem> getMenuItems() => List.unmodifiable(_menuItems);

  List<MenuItem> getItemsByCategory(FoodCategory category) =>
      _menuItems.where((item) => item.category == category).toList();

  List<MenuItem> getAvailableItems() =>
      _menuItems.where((item) => item.isAvailable).toList();

  MenuItem? getItemById(String id) =>
      _menuItems.where((item) => item.id == id).firstOrNull;

  bool get isLoaded => _menuItems.isNotEmpty;

  Future<void> loadFromBackend() async {
    final supabase = AppConfig.supabase;
    final rows = await supabase
        .from('menu_items')
        .select()
        .order('name')
        .order('category');

    _menuItems
      ..clear()
      ..addAll(rows.map(_fromRow));
  }

  Future<MenuItem> updateItem(MenuItem updatedItem) async {
    final supabase = AppConfig.supabase;
    await supabase
        .from('menu_items')
        .update(_toRow(updatedItem))
        .eq('id', updatedItem.id);

    final index = _menuItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _menuItems[index] = updatedItem;
    }
    return updatedItem;
  }

  Future<MenuItem> addItem(MenuItem item) async {
    final supabase = AppConfig.supabase;
    final row = await supabase
        .from('menu_items')
        .insert(_toRow(item))
        .select()
        .single();
    final created = _fromRow(row);
    _menuItems.add(created);
    return created;
  }

  Future<void> toggleAvailability(String itemId) async {
    final item = _menuItems.where((i) => i.id == itemId).firstOrNull;
    if (item == null) return;
    await updateItem(item.copyWith(isAvailable: !item.isAvailable));
  }

  MenuItem _fromRow(Map<String, dynamic> row) => MenuItem(
        id: row['id'],
        name: row['name'],
        description: row['description'] ?? '',
        price: (row['price'] as num).toDouble(),
        category: FoodCategory.values.byName(row['category']),
        imageUrl: row['image_url'] ?? '',
        isAvailable: row['is_available'] ?? true,
        preparationTimeMinutes: row['preparation_time_minutes'] ?? 10,
      );

  Map<String, dynamic> _toRow(MenuItem item) => {
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': item.category.name,
        'image_url': item.imageUrl,
        'is_available': item.isAvailable,
        'preparation_time_minutes': item.preparationTimeMinutes,
      };
}