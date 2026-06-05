import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => _items.isEmpty;

  void addItem(MenuItem menuItem) {
    final existingIndex = _items.indexWhere((item) => item.menuItem.id == menuItem.id);
    if (existingIndex >= 0) {
      _items[existingIndex].increment();
    } else {
      _items.add(CartItem(menuItem: menuItem));
    }
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _items.removeWhere((item) => item.menuItem.id == menuItemId);
    notifyListeners();
  }

  void incrementItem(String menuItemId) {
    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index >= 0) {
      _items[index].increment();
      notifyListeners();
    }
  }

  void decrementItem(String menuItemId) {
    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index >= 0) {
      if (_items[index].quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index].decrement();
      }
      notifyListeners();
    }
  }

  int getQuantity(String menuItemId) {
    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
