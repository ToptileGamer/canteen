import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';

class MenuProvider extends ChangeNotifier {
  final MenuService _menuService = MenuService();

  List<MenuItem> _menuItems = [];
  FoodCategory _selectedCategory = FoodCategory.breakfast;
  bool _isLoading = false;

  List<MenuItem> get menuItems => _menuItems;
  List<MenuItem> get filteredItems =>
      _menuItems.where((item) => item.category == _selectedCategory).toList();
  FoodCategory get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  Future<void> loadMenu() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    _menuItems = _menuService.getMenuItems();

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(FoodCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> toggleAvailability(String itemId) async {
    await _menuService.toggleAvailability(itemId);
    await loadMenu();
  }

  Future<void> updateItem(MenuItem item) async {
    await _menuService.updateItem(item);
    await loadMenu();
  }

  MenuItem? getItemById(String id) => _menuService.getItemById(id);
}
