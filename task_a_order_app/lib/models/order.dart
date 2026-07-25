enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final String customerName;
  final double totalAmount;
  final OrderStatus status;
  final DateTime date;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.status,
    required this.date,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerName: json['customerName'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'totalAmount': totalAmount,
      'status': status.name,
      'date': date.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerName,
    double? totalAmount,
    OrderStatus? status,
    DateTime? date,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }
}
