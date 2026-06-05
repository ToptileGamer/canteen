import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

class PaymentService {
  final _uuid = const Uuid();

  Future<Transaction> processPayment({
    required String userId,
    required double amount,
    required String paymentMethod,
  }) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    // 95% success rate simulation
    final random = Random();
    final isSuccess = random.nextDouble() < 0.95;

    if (!isSuccess) {
      return Transaction(
        id: _uuid.v4(),
        userId: userId,
        amount: amount,
        status: TransactionStatus.failed,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );
    }

    return Transaction(
      id: _uuid.v4(),
      userId: userId,
      amount: amount,
      status: TransactionStatus.success,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );
  }
}
