import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/action_queue.dart';
import 'local_db.dart';
import 'mock_api.dart';

class SyncRepository {
  final LocalDatabase localDb;
  final MockApi mockApi;
  final Connectivity connectivity;

  SyncRepository({
    required this.localDb,
    required this.mockApi,
    required this.connectivity,
  });

  Future<bool> get isOnline async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
           connectivityResult.contains(ConnectivityResult.wifi) ||
           connectivityResult.contains(ConnectivityResult.ethernet);
  }

  // Fetch orders (Network first, then cache. If offline, cache only)
  Future<List<OrderModel>> getOrders() async {
    if (await isOnline) {
      try {
        final serverOrders = await mockApi.fetchOrders();
        await localDb.clearOrders();
        await localDb.insertOrders(serverOrders);
        return serverOrders;
      } catch (e) {
        // Fallback to local
        return await localDb.getAllOrders();
      }
    } else {
      return await localDb.getAllOrders();
    }
  }

  // Update order status (Optimistic update locally, enqueue action if offline)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final order = await localDb.getOrderById(orderId);
    if (order == null) throw Exception('Order not found locally');

    // 1. Optimistic local update
    final updatedOrder = order.copyWith(status: newStatus);
    await localDb.updateOrder(updatedOrder);

    // 2. Try network or enqueue
    if (await isOnline) {
      try {
        await mockApi.updateOrderStatus(orderId, newStatus);
      } catch (e) {
        // Enqueue if network fails unexpectedly
        await _enqueueAction('UPDATE_ORDER_STATUS', orderId, newStatus.name);
      }
    } else {
      // Enqueue offline action
      await _enqueueAction('UPDATE_ORDER_STATUS', orderId, newStatus.name);
    }
  }

  Future<void> _enqueueAction(String actionType, String entityId, String payload) async {
    final item = ActionQueueItem(
      id: const Uuid().v4(),
      actionType: actionType,
      entityId: entityId,
      payload: payload,
      createdAt: DateTime.now(),
    );
    await localDb.insertAction(item);
  }

  // Sync the queue when connection is restored
  Future<void> syncQueue() async {
    if (!(await isOnline)) return;

    final queue = await localDb.getActionQueue();
    if (queue.isEmpty) return;

    for (var item in queue) {
      try {
        if (item.actionType == 'UPDATE_ORDER_STATUS') {
          final status = OrderStatus.values.firstWhere((e) => e.name == item.payload);
          await mockApi.updateOrderStatus(item.entityId, status);
          await localDb.deleteAction(item.id);
        }
      } catch (e) {
        // Stop syncing if an action fails (e.g. server down), we'll try again later
        break;
      }
    }
  }
}
