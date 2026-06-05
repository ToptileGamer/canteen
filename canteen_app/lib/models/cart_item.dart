import 'menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
  });

  double get totalPrice => menuItem.price * quantity;

  void increment() => quantity++;
  void decrement() {
    if (quantity > 1) quantity--;
  }
}
