import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';

class MenuProvider extends ChangeNotifier {
  final MenuService _menuService = MenuService();

  List<MenuItem> _menuItems = [];
  FoodCategory _selectedCategory = FoodCategory.breakfast;
  bool _isLoading = false;
  RealtimeChannel? _channel;

  List<MenuItem> get menuItems => _menuItems;
  List<MenuItem> get filteredItems =>
      _menuItems.where((item) => item.category == _selectedCategory).toList();
  FoodCategory get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  Future<void> loadMenu() async {
    _isLoading = true;
    notifyListeners();

    await _menuService.loadFromBackend();
    _menuItems = _menuService.getMenuItems();

    _isLoading = false;
    notifyListeners();
  }

  /// Subscribes to menu changes so availability/price edits made by staff
  /// appear instantly on every device.
  void subscribeRealtime() {
    unsubscribeRealtime();
    try {
      final supabase = AppConfig.supabase;
      _channel = supabase
          .channel('menu_items')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'menu_items',
            callback: (_) {
              loadMenu();
            },
          )
          .subscribe();
    } catch (_) {
      // realtime unavailable (e.g. not initialized in tests)
    }
  }

  void unsubscribeRealtime() {
    try {
      _channel?.unsubscribe();
    } catch (_) {}
    _channel = null;
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

  Future<MenuItem> addMenuItem(MenuItem item) async {
    final created = await _menuService.addItem(item);
    await loadMenu();
    return created;
  }

  MenuItem? getItemById(String id) => _menuService.getItemById(id);
}