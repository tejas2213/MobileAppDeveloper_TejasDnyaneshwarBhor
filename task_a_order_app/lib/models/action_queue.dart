class ActionQueueItem {
  final String id; // Unique ID for the action
  final String actionType; // e.g., 'UPDATE_ORDER_STATUS'
  final String entityId; // The ID of the order being updated
  final String payload; // JSON string of the new data (e.g. status)
  final DateTime createdAt;

  ActionQueueItem({
    required this.id,
    required this.actionType,
    required this.entityId,
    required this.payload,
    required this.createdAt,
  });

  factory ActionQueueItem.fromMap(Map<String, dynamic> map) {
    return ActionQueueItem(
      id: map['id'],
      actionType: map['actionType'],
      entityId: map['entityId'],
      payload: map['payload'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actionType': actionType,
      'entityId': entityId,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
