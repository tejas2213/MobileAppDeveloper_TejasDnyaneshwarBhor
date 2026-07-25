import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../models/order.dart';

class StatusUpdateScreen extends ConsumerStatefulWidget {
  final String orderId;
  const StatusUpdateScreen({super.key, required this.orderId});

  @override
  ConsumerState<StatusUpdateScreen> createState() => _StatusUpdateScreenState();
}

class _StatusUpdateScreenState extends ConsumerState<StatusUpdateScreen> {
  OrderStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF475569), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Update Status',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ordersState.when(
        data: (orders) {
          final order = orders.firstWhere(
            (o) => o.id == widget.orderId,
            orElse: () => OrderModel(id: '', customerName: '', totalAmount: 0, status: OrderStatus.pending, date: DateTime.now()),
          );
          
          if (order.id.isEmpty) {
            return const Center(child: Text('Order not found'));
          }
          
          _selectedStatus ??= order.status;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Order #${order.id.split('-').last}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Neumorphic/Glass Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 10,
                          offset: const Offset(-4, -4),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<OrderStatus>(
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                        value: _selectedStatus,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        items: OrderStatus.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                _buildStatusIndicator(s),
                                const SizedBox(width: 12),
                                Text(
                                  s.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF334155),
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedStatus = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Select the new status for this order below. Changes will sync automatically.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Gradient Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], // Blue to Purple gradient
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          if (_selectedStatus != null && _selectedStatus != order.status) {
                            await ref.read(ordersProvider.notifier).updateOrderStatus(
                              widget.orderId,
                              _selectedStatus!,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Status updated successfully!'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                              context.pop();
                            }
                          } else {
                            context.pop();
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'SAVE CHANGES',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatusIndicator(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = const Color(0xFFF59E0B); // Orange
        break;
      case OrderStatus.processing:
        color = const Color(0xFF3B82F6); // Blue
        break;
      case OrderStatus.shipped:
        color = const Color(0xFFA855F7); // Purple
        break;
      case OrderStatus.delivered:
        color = const Color(0xFF10B981); // Green
        break;
      case OrderStatus.cancelled:
        color = const Color(0xFFEF4444); // Red
        break;
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
