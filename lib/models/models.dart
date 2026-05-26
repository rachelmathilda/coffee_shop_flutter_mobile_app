// models/coffee.dart
class Coffee {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String imageUrl;
  final List<String> sizes;
  final List<String> coffeeTypes;
  final List<String> addIns;

  const Coffee({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.sizes = const ['S', 'M', 'L'],
    this.coffeeTypes = const ['Arabica', 'Liberica', 'Robusta'],
    this.addIns = const ['Milk', 'Sugar', 'Cream', 'Cocoa', 'Vanilla', 'Salt'],
  });

  factory Coffee.fromMap(Map<String, dynamic> map, String id) {
    return Coffee(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'rating': rating,
    'imageUrl': imageUrl,
  };
}

// models/cart_item.dart
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

// models/discount.dart
class Discount {
  final String id;
  final String label;
  final String description;
  final DateTime validUntil;

  const Discount({
    required this.id,
    required this.label,
    required this.description,
    required this.validUntil,
  });
}

// models/custom_coffee_order.dart
enum CoffeeTemp { hot, iced }

enum SugarLevel { less, normal, high }

class CustomCoffeeOrder {
  CoffeeTemp temp;
  String cupSize;
  SugarLevel sugarLevel;
  String? topping;
  double basePrice;

  CustomCoffeeOrder({
    this.temp = CoffeeTemp.iced,
    this.cupSize = 'M',
    this.sugarLevel = SugarLevel.normal,
    this.topping,
    this.basePrice = 2.00,
  });

  double get totalPrice {
    double price = basePrice;
    if (cupSize == 'L') price += 0.50;
    if (topping != null) price += 0.30;
    return price;
  }
}
