enum TransactionStatus { pending, success, failed }

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final TransactionStatus status;
  final String paymentMethod;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'amount': amount,
        'status': status.name,
        'paymentMethod': paymentMethod,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        userId: json['userId'],
        amount: (json['amount'] as num).toDouble(),
        status: TransactionStatus.values.byName(json['status']),
        paymentMethod: json['paymentMethod'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
