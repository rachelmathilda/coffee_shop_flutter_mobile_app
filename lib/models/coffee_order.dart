import 'package:cloud_firestore/cloud_firestore.dart';

class CoffeeOrder {
  final String id;
  final List<String> itemNames;
  final double total;
  final String status;
  final DateTime createdAt;

  const CoffeeOrder({
    required this.id,
    required this.itemNames,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory CoffeeOrder.fromMap(Map<String, dynamic> map, String id) {
    final items = (map['items'] ?? const []) as List;
    final c = map['createdAt'];
    return CoffeeOrder(
      id: id,
      itemNames: items
          .map((e) => '${(e as Map)['quantity']}x ${e['name']}')
          .toList(),
      total: ((map['total'] ?? 0) as num).toDouble(),
      status: (map['status'] ?? 'pending') as String,
      createdAt: c is Timestamp ? c.toDate() : DateTime.now(),
    );
  }
}
