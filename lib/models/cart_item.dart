import 'coffee.dart';

class CartItem {
  final Coffee coffee;
  int quantity;
  String size;
  String coffeeType;
  List<String> addIns;

  CartItem({
    required this.coffee,
    this.quantity = 1,
    this.size = 'M',
    this.coffeeType = 'Arabica',
    this.addIns = const [],
  });

  double get totalPrice =>
      coffee.price * quantity + (addIns.isNotEmpty ? 0.80 : 0);

  CartItem copyWith({
    int? quantity,
    String? size,
    String? coffeeType,
    List<String>? addIns,
  }) {
    return CartItem(
      coffee: coffee,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      coffeeType: coffeeType ?? this.coffeeType,
      addIns: addIns ?? this.addIns,
    );
  }
}
