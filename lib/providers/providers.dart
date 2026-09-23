import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final coffeeCatalogProvider = StreamProvider<List<Coffee>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('coffees')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Coffee.fromMap(doc.data(), doc.id))
            .toList(),
      );
});

final promoCatalogProvider = StreamProvider<List<Promo>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('promos')
      .orderBy('order')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Promo.fromMap(doc.data(), doc.id))
            .toList(),
      );
});

final discountCatalogProvider = StreamProvider<List<Discount>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('discounts')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Discount.fromMap(doc.data(), doc.id))
            .toList(),
      );
});

final deliveryAddressProvider = StateProvider<DeliveryAddress?>((ref) => null);

final deliveryFeeProvider = StreamProvider<double>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('settings')
      .doc('delivery')
      .snapshots()
      .map((doc) => (doc.data()?['fee'] ?? 1.40).toDouble());
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCatalogProvider = Provider<AsyncValue<List<Coffee>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final catalog = ref.watch(coffeeCatalogProvider);
  return catalog.whenData((coffees) {
    if (query.isEmpty) return coffees;
    return coffees.where((c) => c.name.toLowerCase().contains(query)).toList();
  });
});

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
      if (item.coffee.id == coffeeId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
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

  double get totalPrice =>
      state.fold(0, (total, item) => total + item.totalPrice);
  int get totalItems => state.fold(0, (total, item) => total + item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider.notifier).totalPrice;
});

class CustomCoffeeNotifier extends StateNotifier<CustomCoffeeOrder> {
  CustomCoffeeNotifier() : super(CustomCoffeeOrder());

  void setTemp(CoffeeTemp temp) => state = CustomCoffeeOrder(
    temp: temp,
    coffeeType: state.coffeeType,
    cupSize: state.cupSize,
    sugarLevel: state.sugarLevel,
    topping: state.topping,
  );

  void setCoffeeType(String type) => state = CustomCoffeeOrder(
    temp: state.temp,
    coffeeType: type,
    cupSize: state.cupSize,
    sugarLevel: state.sugarLevel,
    topping: state.topping,
  );

  void setCupSize(String size) => state = CustomCoffeeOrder(
    temp: state.temp,
    coffeeType: state.coffeeType,
    cupSize: size,
    sugarLevel: state.sugarLevel,
    topping: state.topping,
  );

  void setSugarLevel(SugarLevel level) => state = CustomCoffeeOrder(
    temp: state.temp,
    coffeeType: state.coffeeType,
    cupSize: state.cupSize,
    sugarLevel: level,
    topping: state.topping,
  );

  void setTopping(String? topping) => state = CustomCoffeeOrder(
    temp: state.temp,
    coffeeType: state.coffeeType,
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

final authServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});
