import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../models/order.dart';

class DetailScreen extends ConsumerWidget {
  final String orderId;

  const DetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFEDF2F7), // Soft blue/grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF475569), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Elegant Order Details',
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
            (o) => o.id == orderId,
            orElse: () => OrderModel(id: '', customerName: '', totalAmount: 0, status: OrderStatus.pending, date: DateTime.now()),
          );
          
          if (order.id.isEmpty) {
            return const Center(child: Text('Order not found'));
          }

          return Stack(
            children: [
              // Background Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE2E8F0),
                      Color(0xFFF1F5F9),
                    ],
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildMainCard(order),
                            const SizedBox(height: 60), // Space for bottom button
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom floating button
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: _buildUpdateButton(context),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildMainCard(OrderModel order) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1.1,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '#${order.id.split('-').last}',
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 20),
              _buildGlowingBadge(order.status),
            ],
          ),
          const SizedBox(height: 32),
          // Inner Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildInfoRow(Icons.person_outline, 'Customer', order.customerName),
                const SizedBox(height: 24),
                _buildInfoRow(Icons.attach_money, 'Total Amount', '\$${order.totalAmount.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFBEFEA), // Soft peach
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFA67B6C), size: 28), // Brownish icon
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlowingBadge(OrderStatus status) {
    Color glowColor;
    Color gradientStart;
    Color gradientEnd;
    Color textColor = Colors.white;

    switch (status) {
      case OrderStatus.pending:
        glowColor = const Color(0xFFF59E0B).withOpacity(0.6);
        gradientStart = const Color(0xFFFBBF24);
        gradientEnd = const Color(0xFFD97706);
        break;
      case OrderStatus.processing:
        glowColor = const Color(0xFF3B82F6).withOpacity(0.6);
        gradientStart = const Color(0xFF60A5FA);
        gradientEnd = const Color(0xFF2563EB);
        break;
      case OrderStatus.shipped:
        glowColor = const Color(0xFFA855F7).withOpacity(0.6);
        gradientStart = const Color(0xFFC084FC);
        gradientEnd = const Color(0xFF7E22CE);
        break;
      case OrderStatus.delivered:
        glowColor = const Color(0xFF10B981).withOpacity(0.6);
        gradientStart = const Color(0xFF34D399);
        gradientEnd = const Color(0xFF059669);
        break;
      case OrderStatus.cancelled:
        glowColor = const Color(0xFFEF4444).withOpacity(0.6);
        gradientStart = const Color(0xFFF87171);
        gradientEnd = const Color(0xFFDC2626);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF93C5FD), Color(0xFF3B82F6)], // Light blue to darker blue
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => context.push('/orders/${orderId}/update'),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'UPDATE STATUS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
