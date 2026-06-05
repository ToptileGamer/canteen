import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Your cart is empty',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Text('Browse the menu and add items!',
                style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Cart items list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final cartItem = cart.items[index];
              final item = cartItem.menuItem;

              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => cart.removeItem(item.id),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Item emoji
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(item.imageUrl, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text('₹${item.price.toStringAsFixed(2)} each',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                        // Quantity controls
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => cart.decrementItem(item.id),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.remove, size: 18),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text('${cartItem.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              InkWell(
                                onTap: () => cart.incrementItem(item.id),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.add, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('₹${cartItem.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom checkout bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${cart.itemCount} item(s)',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text('₹${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Proceed to Checkout',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
