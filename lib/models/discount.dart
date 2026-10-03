import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class Discount {
  final String id;
  final String type;
  final double value;
  final int buyQty;
  final int freeQty;
  final DateTime validUntil;
  final int order;

  const Discount({
    required this.id,
    required this.type,
    required this.value,
    required this.validUntil,
    this.buyQty = 1,
    this.freeQty = 2,
    this.order = 0,
  });

  bool get isBogo => type == 'bogo';
  bool get isExpired => DateTime.now().isAfter(validUntil);

  double amountFor(List<CartItem> items) {
    final subtotal = items.fold<double>(0, (t, i) => t + i.totalPrice);
    if (isBogo) {
      final group = buyQty + freeQty;
      double free = 0;
      for (final i in items) {
        final freeCount = (i.quantity ~/ group) * freeQty;
        free += freeCount * i.unitPrice;
      }
      return free;
    }
    return subtotal * value / 100;
  }

  factory Discount.fromMap(Map<String, dynamic> map, String id) {
    final v = map['validUntil'];
    return Discount(
      id: id,
      type: (map['type'] ?? 'percent') as String,
      value: ((map['value'] ?? 0) as num).toDouble(),
      buyQty: ((map['buy'] ?? 1) as num).toInt(),
      freeQty: ((map['get'] ?? 2) as num).toInt(),
      order: ((map['order'] ?? 0) as num).toInt(),
      validUntil: v is Timestamp ? v.toDate() : DateTime.now(),
    );
  }
}
