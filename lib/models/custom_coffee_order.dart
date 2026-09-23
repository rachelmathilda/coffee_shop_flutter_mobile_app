enum CoffeeTemp { hot, iced }

enum SugarLevel { less, normal, high }

class CustomCoffeeOrder {
  CoffeeTemp temp;
  String coffeeType;
  String cupSize;
  SugarLevel sugarLevel;
  String? topping;
  double basePrice;

  CustomCoffeeOrder({
    this.temp = CoffeeTemp.iced,
    this.coffeeType = 'Arabica',
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
