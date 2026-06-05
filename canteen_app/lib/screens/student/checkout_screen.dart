import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../models/order.dart';
import '../../models/time_slot.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/time_slot_picker.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  TimeSlot? _selectedSlot;
  String _paymentMethod = 'UPI';
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadTimeSlots();
    });
  }

  Future<void> _placeOrder() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup time slot'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    // Convert cart items to order items
    final orderItems = cart.items.map((ci) => ci.menuItem.toOrderItem(ci.quantity)).toList();

    final order = await orderProvider.checkout(
      userId: auth.user!.id,
      items: orderItems,
      amount: cart.totalAmount,
      paymentMethod: _paymentMethod,
      pickupStartTime: _selectedSlot!.startTime,
      pickupEndTime: _selectedSlot!.endTime,
    );

    if (order != null && mounted) {
      cart.clearCart();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: order.id),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.receipt, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Order Summary',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    ...cart.items.map((ci) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text('${ci.quantity}x ', style: const TextStyle(color: AppColors.textSecondary)),
                              Expanded(child: Text(ci.menuItem.name)),
                              Text('₹${ci.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('₹${cart.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Student info
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.user?.name ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(auth.user?.rollNumber ?? '',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time slot picker
            const Text('Select Pickup Time Slot *',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            TimeSlotPicker(
              slots: orderProvider.availableSlots,
              selectedSlot: _selectedSlot,
              onSelect: (slot) => setState(() => _selectedSlot = slot),
            ),

            if (orderProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(orderProvider.error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
            const SizedBox(height: 16),

            // Payment method
            const Text('Payment Method',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            _PaymentMethodCard(
              icon: Icons.phone_android,
              label: 'UPI (Google Pay / PhonePe / Paytm)',
              selected: _paymentMethod == 'UPI',
              onTap: () => setState(() => _paymentMethod = 'UPI'),
            ),
            const SizedBox(height: 8),
            _PaymentMethodCard(
              icon: Icons.credit_card,
              label: 'Card (Debit / Credit)',
              selected: _paymentMethod == 'Card',
              onTap: () => setState(() => _paymentMethod = 'Card'),
            ),
            const SizedBox(height: 16),

            // Terms
            CheckboxListTile(
              value: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              title: const Text('I agree to the terms and conditions', style: TextStyle(fontSize: 14)),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // Place order button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (orderProvider.isLoading || _selectedSlot == null) ? null : _placeOrder,
                icon: orderProvider.isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.payment),
                label: Text(
                  orderProvider.isLoading
                      ? 'Processing Payment...'
                      : 'Pay ₹${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
            if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

extension on MenuItem {
  OrderItem toOrderItem(int quantity) => OrderItem(
        menuItemId: id,
        menuItemName: name,
        quantity: quantity,
        unitPrice: price,
      );
}
