import 'dart:convert';
import 'dart:math';
import '../models/order.dart';

class MockApi {
  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Initial dummy data
  final List<OrderModel> _serverOrders = [
    OrderModel(
      id: 'ord-101',
      customerName: 'Alice Smith',
      totalAmount: 120.50,
      status: OrderStatus.pending,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    OrderModel(
      id: 'ord-102',
      customerName: 'Bob Johnson',
      totalAmount: 45.00,
      status: OrderStatus.shipped,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OrderModel(
      id: 'ord-103',
      customerName: 'Charlie Brown',
      totalAmount: 330.00,
      status: OrderStatus.processing,
      date: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    OrderModel(
      id: 'ord-104',
      customerName: 'Diana Prince',
      totalAmount: 99.99,
      status: OrderStatus.delivered,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  Future<List<OrderModel>> fetchOrders() async {
    await _delay();
    // Simulate server randomly failing occasionally
    // if (Random().nextDouble() < 0.1) {
    //   throw Exception('Server error: 500 Internal Server Error');
    // }
    return List.from(_serverOrders); // Return a copy
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _delay();
    
    final index = _serverOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _serverOrders[index] = _serverOrders[index].copyWith(status: newStatus);
    } else {
      throw Exception('Order not found on server');
    }
  }
}
