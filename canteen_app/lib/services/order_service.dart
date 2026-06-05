import 'dart:math';
import '../models/order.dart';
import '../models/time_slot.dart';

class OrderService {
  final List<Order> _orders = [];
  final Map<String, int> _slotOrderCounts = {};
  static const int maxOrdersPerSlot = 30;

  List<Order> get allOrders => List.unmodifiable(_orders);

  List<Order> getOrdersByUser(String userId) =>
      _orders.where((o) => o.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Order> getOrdersByPickupSlot(DateTime slotStart, DateTime slotEnd) =>
      _orders.where((o) =>
          o.pickupStartTime == slotStart && o.pickupEndTime == slotEnd).toList();

  List<Order> getActiveOrders() =>
      _orders.where((o) =>
          o.status == OrderStatus.paidPendingApproval ||
          o.status == OrderStatus.preparing ||
          o.status == OrderStatus.readyForPickup).toList()
        ..sort((a, b) => a.pickupStartTime.compareTo(b.pickupStartTime));

  List<Order> getPendingApproval() =>
      _orders.where((o) => o.status == OrderStatus.paidPendingApproval).toList()
        ..sort((a, b) => a.pickupStartTime.compareTo(b.pickupStartTime));

  List<Order> getPreparing() =>
      _orders.where((o) => o.status == OrderStatus.preparing).toList()
        ..sort((a, b) => a.pickupStartTime.compareTo(b.pickupStartTime));

  List<Order> getReadyForPickup() =>
      _orders.where((o) => o.status == OrderStatus.readyForPickup).toList()
        ..sort((a, b) => a.pickupStartTime.compareTo(b.pickupStartTime));

  List<Order> getCompletedOrders() =>
      _orders.where((o) => o.status == OrderStatus.completed ||
          o.status == OrderStatus.cancelled).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Order> getCompletedToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _orders.where((o) =>
        o.status == OrderStatus.completed &&
        o.createdAt.isAfter(startOfDay)).toList();
  }

  double get todayRevenue {
    return getCompletedToday().fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  int get todayOrderCount => getCompletedToday().length;

  bool canPlaceOrderInSlot(DateTime startTime, DateTime endTime) {
    final key = '${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}';
    final count = _slotOrderCounts[key] ?? 0;
    return count < maxOrdersPerSlot;
  }

  int getSlotOrderCount(DateTime startTime, DateTime endTime) {
    final key = '${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}';
    return _slotOrderCounts[key] ?? 0;
  }

  Future<List<TimeSlot>> getAvailableTimeSlots() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final slots = <TimeSlot>[];

    // Generate slots from current time + 15 min cutoff up to next 4 hours
    final startHour = now.hour;
    final startMinute = now.minute;

    // Round up to next 30-min interval
    int currentMinute = ((startMinute + 15) ~/ 30) * 30;
    int currentHour = startHour;
    if (currentMinute >= 60) {
      currentMinute = 0;
      currentHour++;
    }

    for (int i = 0; i < 8; i++) {
      final slotStart = DateTime(now.year, now.month, now.day, currentHour, currentMinute);
      final slotEnd = slotStart.add(const Duration(minutes: 30));

      // Skip past slots
      if (slotStart.isBefore(now) || slotStart.difference(now).inMinutes < 15) {
        currentMinute += 30;
        if (currentMinute >= 60) {
          currentMinute = 0;
          currentHour++;
        }
        continue;
      }

      // Skip if past 8 PM (canteen closing)
      if (currentHour >= 20) break;

      final key = '${slotStart.millisecondsSinceEpoch}-${slotEnd.millisecondsSinceEpoch}';
      final orderCount = _slotOrderCounts[key] ?? 0;

      slots.add(TimeSlot(
        startTime: slotStart,
        endTime: slotEnd,
        maxOrders: maxOrdersPerSlot,
        currentOrders: orderCount,
        isAvailable: orderCount < maxOrdersPerSlot && currentHour < 20,
      ));

      currentMinute += 30;
      if (currentMinute >= 60) {
        currentMinute = 0;
        currentHour++;
      }
    }

    return slots;
  }

  Future<Order> placeOrder({
    required String userId,
    required List<OrderItem> items,
    required String transactionId,
    required DateTime pickupStartTime,
    required DateTime pickupEndTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);

    // Random order number for display
    final random = Random();
    final orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}${random.nextInt(100)}';

    final order = Order(
      id: orderNumber,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      status: OrderStatus.paidPendingApproval,
      createdAt: DateTime.now(),
      pickupStartTime: pickupStartTime,
      pickupEndTime: pickupEndTime,
      transactionId: transactionId,
    );

    _orders.add(order);

    // Track slot count
    final key = '${pickupStartTime.millisecondsSinceEpoch}-${pickupEndTime.millisecondsSinceEpoch}';
    _slotOrderCounts[key] = (_slotOrderCounts[key] ?? 0) + 1;

    return order;
  }

  Future<Order> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) throw Exception('Order not found');

    _orders[index] = _orders[index].copyWith(status: newStatus);
    return _orders[index];
  }
}
