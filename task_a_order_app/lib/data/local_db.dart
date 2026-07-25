import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/order.dart';
import '../models/action_queue.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();

  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orders_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE orders (
  id $idType,
  customerName $textType,
  totalAmount $realType,
  status $textType,
  date $textType
  )
''');

    await db.execute('''
CREATE TABLE action_queue (
  id $idType,
  actionType $textType,
  entityId $textType,
  payload $textType,
  createdAt $textType
  )
''');
  }

  // --- Orders ---
  Future<void> insertOrder(OrderModel order) async {
    final db = await instance.database;
    await db.insert('orders', order.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrders(List<OrderModel> orders) async {
    final db = await instance.database;
    Batch batch = db.batch();
    for (var order in orders) {
      batch.insert('orders', order.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<OrderModel>> getAllOrders() async {
    final db = await instance.database;
    final result = await db.query('orders', orderBy: 'date DESC');
    return result.map((json) => OrderModel.fromJson(json)).toList();
  }
  
  Future<OrderModel?> getOrderById(String id) async {
    final db = await instance.database;
    final result = await db.query('orders', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return OrderModel.fromJson(result.first);
    }
    return null;
  }

  Future<void> updateOrder(OrderModel order) async {
    final db = await instance.database;
    await db.update(
      'orders',
      order.toJson(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<void> clearOrders() async {
    final db = await instance.database;
    await db.delete('orders');
  }

  // --- Action Queue ---
  Future<void> insertAction(ActionQueueItem item) async {
    final db = await instance.database;
    await db.insert('action_queue', item.toMap());
  }

  Future<List<ActionQueueItem>> getActionQueue() async {
    final db = await instance.database;
    final result = await db.query('action_queue', orderBy: 'createdAt ASC');
    return result.map((map) => ActionQueueItem.fromMap(map)).toList();
  }

  Future<void> deleteAction(String id) async {
    final db = await instance.database;
    await db.delete(
      'action_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
