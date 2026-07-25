import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/order.dart';
import '../data/local_db.dart';
import '../data/mock_api.dart';
import '../data/sync_repository.dart';

final localDbProvider = Provider((ref) => LocalDatabase.instance);
final mockApiProvider = Provider((ref) => MockApi());

final syncRepositoryProvider = Provider((ref) {
  return SyncRepository(
    localDb: ref.watch(localDbProvider),
    mockApi: ref.watch(mockApiProvider),
    connectivity: Connectivity(),
  );
});

// Connectivity Stream Provider
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

// Filter State Provider
enum OrderFilter { all, pending, processing, shipped, delivered, cancelled }

class OrderFilterNotifier extends Notifier<OrderFilter> {
  @override
  OrderFilter build() => OrderFilter.all;

  void updateFilter(OrderFilter newFilter) {
    state = newFilter;
  }
}

final orderFilterProvider = NotifierProvider<OrderFilterNotifier, OrderFilter>(() {
  return OrderFilterNotifier();
});

// Orders Notifier
class OrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  late SyncRepository _repository;

  @override
  Future<List<OrderModel>> build() async {
    _repository = ref.watch(syncRepositoryProvider);
    
    // Listen to connectivity changes to trigger sync
    ref.listen<AsyncValue<List<ConnectivityResult>>>(
      connectivityProvider,
      (previous, next) {
        final results = next.value;
        if (results != null && (
            results.contains(ConnectivityResult.mobile) || 
            results.contains(ConnectivityResult.wifi) || 
            results.contains(ConnectivityResult.ethernet)
        )) {
          _syncAndRefresh();
        }
      },
    );

    return _repository.getOrders();
  }

  Future<void> _syncAndRefresh() async {
    await _repository.syncQueue();
    // Refresh list after syncing
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getOrders());
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    // Optimistically update the UI while processing
    final previousState = state;
    if (state.hasValue) {
      final updatedList = state.value!.map((o) {
        if (o.id == orderId) return o.copyWith(status: newStatus);
        return o;
      }).toList();
      state = AsyncValue.data(updatedList);
    }

    try {
      await _repository.updateOrderStatus(orderId, newStatus);
      // Wait for repository to complete its optimistic queue logic
    } catch (e, st) {
      // Revert on local failure (should rarely happen with offline-first)
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getOrders());
  }
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>(() {
  return OrdersNotifier();
});

// Filtered Orders Provider
final filteredOrdersProvider = Provider<List<OrderModel>>((ref) {
  final ordersState = ref.watch(ordersProvider);
  final filter = ref.watch(orderFilterProvider);

  return ordersState.maybeWhen(
    data: (orders) {
      if (filter == OrderFilter.all) return orders;
      final targetStatus = OrderStatus.values.firstWhere((e) => e.name == filter.name);
      return orders.where((o) => o.status == targetStatus).toList();
    },
    orElse: () => [],
  );
});
