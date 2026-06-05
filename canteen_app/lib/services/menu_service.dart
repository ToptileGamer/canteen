import '../models/menu_item.dart';
import 'mock_data.dart';

class MenuService {
  List<MenuItem> _menuItems = [...MockData.menuItems];

  List<MenuItem> getMenuItems() => List.unmodifiable(_menuItems);

  List<MenuItem> getItemsByCategory(FoodCategory category) =>
      _menuItems.where((item) => item.category == category).toList();

  List<MenuItem> getAvailableItems() =>
      _menuItems.where((item) => item.isAvailable).toList();

  MenuItem? getItemById(String id) =>
      _menuItems.where((item) => item.id == id).firstOrNull;

  Future<MenuItem> updateItem(MenuItem updatedItem) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _menuItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _menuItems[index] = updatedItem;
    }
    return updatedItem;
  }

  Future<MenuItem> addItem(MenuItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _menuItems.add(item);
    return item;
  }

  Future<void> toggleAvailability(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _menuItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final current = _menuItems[index];
      _menuItems[index] = current.copyWith(isAvailable: !current.isAvailable);
    }
  }
}
