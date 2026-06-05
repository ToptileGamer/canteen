import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/time_slot.dart';
import '../models/transaction.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();

  List<Order> _userOrders = [];
  List<Order> _activeOrders = [];
  List<Order> _pendingOrders = [];
  List<Order> _preparingOrders = [];
  List<Order> _readyOrders = [];
  List<Order> _completedOrders = [];
  List<TimeSlot> _availableSlots = [];
  bool _isLoading = false;
  String? _error;

  // Staff analytics
  double _todayRevenue = 0;
  int _todayOrderCount = 0;

  List<Order> get userOrders => _userOrders;
  List<Order> get activeOrders => _activeOrders;
  List<Order> get pendingOrders => _pendingOrders;
  List<Order> get preparingOrders => _preparingOrders;
  List<Order> get readyOrders => _readyOrders;
  List<Order> get completedOrders => _completedOrders;
  List<TimeSlot> get availableSlots => _availableSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get todayRevenue => _todayRevenue;
  int get todayOrderCount => _todayOrderCount;

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _userOrders = _orderService.getOrdersByUser(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadActiveOrders() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _activeOrders = _orderService.getActiveOrders();
    _pendingOrders = _orderService.getPendingApproval();
    _preparingOrders = _orderService.getPreparing();
    _readyOrders = _orderService.getReadyForPickup();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCompletedOrders() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _completedOrders = _orderService.getCompletedOrders();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTimeSlots() async {
    _availableSlots = await _orderService.getAvailableTimeSlots();
    notifyListeners();
  }

  Future<void> loadAnalytics() async {
    _todayRevenue = _orderService.todayRevenue;
    _todayOrderCount = _orderService.todayOrderCount;
    notifyListeners();
  }

  bool canPlaceOrderInSlot(DateTime start, DateTime end) {
    return _orderService.canPlaceOrderInSlot(start, end);
  }

  int getSlotOrderCount(DateTime start, DateTime end) {
    return _orderService.getSlotOrderCount(start, end);
  }

  Future<Order?> placeOrder({
    required String userId,
    required List<OrderItem> items,
    required String transactionId,
    required DateTime pickupStartTime,
    required DateTime pickupEndTime,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check slot availability
      if (!_orderService.canPlaceOrderInSlot(pickupStartTime, pickupEndTime)) {
        _error = 'This time slot is full. Please choose another.';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final order = await _orderService.placeOrder(
        userId: userId,
        items: items,
        transactionId: transactionId,
        pickupStartTime: pickupStartTime,
        pickupEndTime: pickupEndTime,
      );

      _userOrders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      await loadActiveOrders();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Simulate payment and order placement
  Future<Order?> checkout({
    required String userId,
    required List<OrderItem> items,
    required double amount,
    required String paymentMethod,
    required DateTime pickupStartTime,
    required DateTime pickupEndTime,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Step 1: Process payment
    final transaction = await _paymentService.processPayment(
      userId: userId,
      amount: amount,
      paymentMethod: paymentMethod,
    );

    if (transaction.status == TransactionStatus.failed) {
      _error = 'Payment failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return null;
    }

    // Step 2: Place order only after successful payment
    final order = await placeOrder(
      userId: userId,
      items: items,
      transactionId: transaction.id,
      pickupStartTime: pickupStartTime,
      pickupEndTime: pickupEndTime,
    );

    _isLoading = false;
    notifyListeners();
    return order;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
