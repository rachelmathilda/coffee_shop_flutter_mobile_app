class CartItem {
  final String key;
  final String coffeeId;
  final String name;
  final String image;
  final double unitPrice;
  final int quantity;
  final Map<String, dynamic> options;
  final bool isCustom;

  const CartItem({
    required this.key,
    required this.coffeeId,
    required this.name,
    required this.image,
    required this.unitPrice,
    required this.quantity,
    this.options = const {},
    this.isCustom = false,
  });

  double get totalPrice => unitPrice * quantity;

  String get optionSummary {
    final parts = <String>[];
    options.forEach((k, v) {
      if (v == null) return;
      if (v is List) {
        if (v.isNotEmpty) parts.add(v.join(', '));
      } else if ('$v'.isNotEmpty) {
        parts.add('$v');
      }
    });
    return parts.join(' · ');
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      key: key,
      coffeeId: coffeeId,
      name: name,
      image: image,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      options: options,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'coffeeId': coffeeId,
        'name': name,
        'image': image,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'options': options,
        'isCustom': isCustom,
      };

  factory CartItem.fromJson(Map<String, dynamic> j) {
    return CartItem(
      key: j['key'] as String,
      coffeeId: (j['coffeeId'] ?? '') as String,
      name: (j['name'] ?? '') as String,
      image: (j['image'] ?? '') as String,
      unitPrice: ((j['unitPrice'] ?? 0) as num).toDouble(),
      quantity: ((j['quantity'] ?? 1) as num).toInt(),
      options: Map<String, dynamic>.from((j['options'] ?? {}) as Map),
      isCustom: (j['isCustom'] ?? false) as bool,
    );
  }
}
