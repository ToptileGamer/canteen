class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final int maxOrders;
  final int currentOrders;
  final bool isAvailable;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    this.maxOrders = 30,
    this.currentOrders = 0,
    this.isAvailable = true,
  });

  bool get isFull => currentOrders >= maxOrders;
  int get remainingSpots => maxOrders - currentOrders;

  String get label {
    final f = _formatTime;
    return '${f(startTime)} - ${f(endTime)}';
  }

  String get shortLabel {
    final f = _formatTime;
    return '${f(startTime)}';
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }

  TimeSlot copyWith({
    DateTime? startTime,
    DateTime? endTime,
    int? maxOrders,
    int? currentOrders,
    bool? isAvailable,
  }) {
    return TimeSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxOrders: maxOrders ?? this.maxOrders,
      currentOrders: currentOrders ?? this.currentOrders,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
