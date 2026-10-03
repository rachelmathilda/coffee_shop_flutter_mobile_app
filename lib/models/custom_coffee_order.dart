class CustomCoffeeOrder {
  final bool iced;
  final String coffeeType;
  final String cupSize;
  final int sugar;
  final String topping;

  const CustomCoffeeOrder({
    this.iced = true,
    this.coffeeType = 'Liberica',
    this.cupSize = 'L',
    this.sugar = 1,
    this.topping = 'Caramel',
  });

  CustomCoffeeOrder copyWith({
    bool? iced,
    String? coffeeType,
    String? cupSize,
    int? sugar,
    String? topping,
  }) {
    return CustomCoffeeOrder(
      iced: iced ?? this.iced,
      coffeeType: coffeeType ?? this.coffeeType,
      cupSize: cupSize ?? this.cupSize,
      sugar: sugar ?? this.sugar,
      topping: topping ?? this.topping,
    );
  }
}
