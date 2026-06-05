enum OrderStatus {
  paidPendingApproval('Paid / Pending Approval'),
  preparing('Preparing'),
  readyForPickup('Ready for Pickup'),
  completed('Completed'),
  cancelled('Cancelled');

  final String displayName;
  const OrderStatus(this.displayName);
}

class OrderItem {
  final String menuItemId;
  final String menuItemName;
  final int quantity;
  final double unitPrice;

  double get totalPrice => unitPrice * quantity;

  const OrderItem({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
        'menuItemId': menuItemId,
        'menuItemName': menuItemName,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        menuItemId: json['menuItemId'],
        menuItemName: json['menuItemName'],
        quantity: json['quantity'],
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime pickupStartTime;
  final DateTime pickupEndTime;
  final String transactionId;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.pickupStartTime,
    required this.pickupEndTime,
    required this.transactionId,
  });

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      pickupStartTime: pickupStartTime,
      pickupEndTime: pickupEndTime,
      transactionId: transactionId,
    );
  }

  String get pickupSlotLabel {
    final f = _formatTime;
    return '${f(pickupStartTime)} - ${f(pickupEndTime)}';
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'items': items.map((i) => i.toJson()).toList(),
        'totalAmount': totalAmount,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'pickupStartTime': pickupStartTime.toIso8601String(),
        'pickupEndTime': pickupEndTime.toIso8601String(),
        'transactionId': transactionId,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        userId: json['userId'],
        items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: OrderStatus.values.byName(json['status']),
        createdAt: DateTime.parse(json['createdAt']),
        pickupStartTime: DateTime.parse(json['pickupStartTime']),
        pickupEndTime: DateTime.parse(json['pickupEndTime']),
        transactionId: json['transactionId'],
      );
}
