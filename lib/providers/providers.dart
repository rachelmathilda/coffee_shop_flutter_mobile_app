import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

// ── Dummy data ──────────────────────────────────────────────────
final dummyCoffees = [
  Coffee(
    id: '1',
    name: 'Black Coffee',
    price: 1.80,
    rating: 4.7,
    imageUrl:
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
  ),
  Coffee(
    id: '2',
    name: 'Espresso',
    price: 1.20,
    rating: 4.9,
    imageUrl:
        'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=400',
  ),
  Coffee(
    id: '3',
    name: 'Mocha',
    price: 1.60,
    rating: 4.7,
    imageUrl:
        'https://images.unsplash.com/photo-1572286258217-d0b3e9e0f08b?w=400',
  ),
  Coffee(
    id: '4',
    name: 'Americano',
    price: 1.30,
    rating: 4.8,
    imageUrl:
        'https://images.unsplash.com/photo-1521302080334-4bebac2763a6?w=400',
  ),
  Coffee(
    id: '5',
    name: 'Matcha Latte',
    price: 2.10,
    rating: 4.5,
    imageUrl: 'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?w=400',
  ),
  Coffee(
    id: '6',
    name: 'Milk Coffee',
    price: 1.50,
    rating: 4.6,
    imageUrl:
        'https://images.unsplash.com/photo-1485808191679-5f86510bd9d4?w=400',
  ),
];

final dummyDiscounts = [
  Discount(
    id: '1',
    label: '70% off',
    description: '',
    validUntil: DateTime(2025, 7, 4),
  ),
  Discount(
    id: '2',
    label: '30% off',
    description: '',
    validUntil: DateTime(2025, 7, 4),
  ),
  Discount(
    id: '3',
    label: '40% off',
    description: '',
    validUntil: DateTime(2025, 7, 4),
  ),
  Discount(
    id: '4',
    label: 'Buy 1\nGet 2',
    description: '',
    validUntil: DateTime(2025, 7, 4),
  ),
];

// ── Catalog provider ────────────────────────────────────────────
final catalogProvider = Provider<List<Coffee>>((ref) => dummyCoffees);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCatalogProvider = Provider<List<Coffee>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final coffees = ref.watch(catalogProvider);
  if (query.isEmpty) return coffees;
  return coffees.where((c) => c.name.toLowerCase().contains(query)).toList();
});

// ── Cart provider ───────────────────────────────────────────────
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(
    Coffee coffee, {
    String size = 'M',
    String coffeeType = 'Arabica',
    List<String> addIns = const [],
  }) {
    final idx = state.indexWhere(
      (item) =>
          item.coffee.id == coffee.id &&
          item.size == size &&
          item.coffeeType == coffeeType,
    );
    if (idx >= 0) {
      final updated = List<CartItem>.from(state);
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
      state = updated;
    } else {
      state = [
        ...state,
        CartItem(
          coffee: coffee,
          size: size,
          coffeeType: coffeeType,
          addIns: addIns,
        ),
      ];
    }
  }

  void removeItem(String coffeeId) {
    state = state.where((item) => item.coffee.id != coffeeId).toList();
  }

  void increment(String coffeeId) {
    state = state.map((item) {
      if (item.coffee.id == coffeeId)
        return item.copyWith(quantity: item.quantity + 1);
      return item;
    }).toList();
  }

  void decrement(String coffeeId) {
    state = state.map((item) {
      if (item.coffee.id == coffeeId && item.quantity > 1) {
        return item.copyWith(quantity: item.quantity - 1);
      }
      return item;
    }).toList();
  }

  void clear() => state = [];

  double get totalPrice => state.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider.notifier).totalPrice;
});

// ── Custom coffee provider ──────────────────────────────────────
class CustomCoffeeNotifier extends StateNotifier<CustomCoffeeOrder> {
  CustomCoffeeNotifier() : super(CustomCoffeeOrder());

  void setTemp(CoffeeTemp temp) => state = CustomCoffeeOrder(
    temp: temp,
    cupSize: state.cupSize,
    sugarLevel: state.sugarLevel,
    topping: state.topping,
  );
  void setCupSize(String size) => state = CustomCoffeeOrder(
    temp: state.temp,
    cupSize: size,
    sugarLevel: state.sugarLevel,
    topping: state.topping,
  );
  void setSugarLevel(SugarLevel level) => state = CustomCoffeeOrder(
    temp: state.temp,
    cupSize: state.cupSize,
    sugarLevel: level,
    topping: state.topping,
  );
  void setTopping(String? topping) => state = CustomCoffeeOrder(
    temp: state.temp,
    cupSize: state.cupSize,
    sugarLevel: state.sugarLevel,
    topping: topping,
  );
  void reset() => state = CustomCoffeeOrder();
}

final customCoffeeProvider =
    StateNotifierProvider<CustomCoffeeNotifier, CustomCoffeeOrder>(
      (ref) => CustomCoffeeNotifier(),
    );

// ── Auth provider ───────────────────────────────────────────────
final authServiceProvider = Provider<FirebaseService>(
  (ref) => FirebaseService(),
);

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});
