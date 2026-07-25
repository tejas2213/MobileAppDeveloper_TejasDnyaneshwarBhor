import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:task_a_order_app/data/sync_repository.dart';
import 'package:task_a_order_app/data/local_db.dart';
import 'package:task_a_order_app/data/mock_api.dart';
import 'package:task_a_order_app/models/order.dart';
import 'package:task_a_order_app/models/action_queue.dart';

// Mocks
class FakeLocalDatabase implements LocalDatabase {
  List<OrderModel> orders = [];
  List<ActionQueueItem> queue = [];

  @override
  Future<void> clearOrders() async => orders.clear();

  @override
  Future<void> insertOrders(List<OrderModel> newOrders) async => orders.addAll(newOrders);

  @override
  Future<List<OrderModel>> getAllOrders() async => orders;

  @override
  Future<OrderModel?> getOrderById(String id) async {
    try { return orders.firstWhere((o) => o.id == id); } catch (_) { return null; }
  }

  @override
  Future<void> updateOrder(OrderModel order) async {
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index != -1) orders[index] = order;
  }

  @override
  Future<void> insertAction(ActionQueueItem item) async => queue.add(item);

  @override
  Future<List<ActionQueueItem>> getActionQueue() async => List.from(queue);

  @override
  Future<void> deleteAction(String id) async => queue.removeWhere((q) => q.id == id);
  
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMockApi implements MockApi {
  bool shouldFail = false;
  List<OrderModel> serverOrders = [
    OrderModel(
      id: 'ord-101',
      customerName: 'Test',
      totalAmount: 100,
      status: OrderStatus.pending,
      date: DateTime.now(),
    )
  ];

  @override
  Future<List<OrderModel>> fetchOrders() async {
    if (shouldFail) throw Exception('Network error');
    return serverOrders;
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    if (shouldFail) throw Exception('Network error');
    final index = serverOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      serverOrders[index] = serverOrders[index].copyWith(status: newStatus);
    }
  }
}

class FakeConnectivity implements Connectivity {
  List<ConnectivityResult> currentResult = [ConnectivityResult.wifi];

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => currentResult;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value(currentResult);
}

void main() {
  late FakeLocalDatabase localDb;
  late FakeMockApi mockApi;
  late FakeConnectivity connectivity;
  late SyncRepository repository;

  setUp(() {
    localDb = FakeLocalDatabase();
    mockApi = FakeMockApi();
    connectivity = FakeConnectivity();

    repository = SyncRepository(
      localDb: localDb,
      mockApi: mockApi,
      connectivity: connectivity,
    );
  });

  test('fetch orders when online syncs cache', () async {
    connectivity.currentResult = [ConnectivityResult.wifi];
    
    final orders = await repository.getOrders();
    
    expect(orders.length, 1);
    expect(orders.first.id, 'ord-101');
    expect(localDb.orders.length, 1);
  });

  test('update order when offline enqueues action and updates local cache', () async {
    // Setup initial state
    localDb.orders.add(mockApi.serverOrders.first);
    connectivity.currentResult = [ConnectivityResult.none]; // Offline

    await repository.updateOrderStatus('ord-101', OrderStatus.shipped);

    // Assert local update
    expect(localDb.orders.first.status, OrderStatus.shipped);
    
    // Assert queue
    expect(localDb.queue.length, 1);
    expect(localDb.queue.first.actionType, 'UPDATE_ORDER_STATUS');
    expect(localDb.queue.first.payload, OrderStatus.shipped.name);
    
    // Server should remain unchanged since offline
    expect(mockApi.serverOrders.first.status, OrderStatus.pending);
  });

  test('sync queue processes items when online', () async {
    // Setup initial state
    localDb.orders.add(mockApi.serverOrders.first);
    localDb.queue.add(ActionQueueItem(
      id: 'q1',
      actionType: 'UPDATE_ORDER_STATUS',
      entityId: 'ord-101',
      payload: OrderStatus.delivered.name,
      createdAt: DateTime.now(),
    ));

    connectivity.currentResult = [ConnectivityResult.wifi]; // Online

    await repository.syncQueue();

    // Assert queue is empty
    expect(localDb.queue.isEmpty, true);
    
    // Assert server is updated
    expect(mockApi.serverOrders.first.status, OrderStatus.delivered);
  });
}
