import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../services/otp_service.dart';

final prefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final authServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

final otpServiceProvider = Provider<OtpService>((ref) => OtpService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((s) => s.exists ? AppUser.fromMap(s.id, s.data()!) : null);
});

class LanguageNotifier extends StateNotifier<String> {
  final SharedPreferences prefs;
  LanguageNotifier(this.prefs) : super(prefs.getString('lang') ?? 'en');

  Future<void> change(String lang) async {
    if (!supportedLanguages.contains(lang)) return;
    state = lang;
    await prefs.setString('lang', lang);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier(ref.watch(prefsProvider));
});

final stringsProvider = Provider<Strings>((ref) => Strings(ref.watch(languageProvider)));

final settingsProvider = StreamProvider<AppSettings>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('settings')
      .doc('app')
      .snapshots()
      .map((d) => AppSettings.fromMap(d.data()));
});

final appSettingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(settingsProvider).valueOrNull ?? const AppSettings();
});

final coffeesProvider = StreamProvider<List<Coffee>>((ref) {
  ref.watch(authStateProvider);
  return ref
      .watch(firestoreProvider)
      .collection('coffees')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map((d) => Coffee.fromMap(d.data(), d.id)).toList());
});

final promosProvider = StreamProvider<List<Promo>>((ref) {
  ref.watch(authStateProvider);
  return ref
      .watch(firestoreProvider)
      .collection('promos')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map((d) => Promo.fromMap(d.data(), d.id)).toList());
});

final discountsProvider = StreamProvider<List<Discount>>((ref) {
  ref.watch(authStateProvider);
  return ref
      .watch(firestoreProvider)
      .collection('discounts')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map((d) => Discount.fromMap(d.data(), d.id)).toList());
});

final ordersProvider = StreamProvider<List<CoffeeOrder>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(firestoreProvider)
      .collection('orders')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .map((s) {
    final list = s.docs.map((d) => CoffeeOrder.fromMap(d.data(), d.id)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  });
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCoffeesProvider = Provider<AsyncValue<List<Coffee>>>((ref) {
  final q = ref.watch(searchQueryProvider).trim().toLowerCase();
  return ref.watch(coffeesProvider).whenData(
        (list) => q.isEmpty ? list : list.where((c) => c.name.toLowerCase().contains(q)).toList(),
      );
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  final SharedPreferences prefs;
  static const _key = 'cart_v2';

  CartNotifier(this.prefs) : super(const []) {
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        state = list.map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      } catch (_) {
        state = const [];
      }
    }
  }

  void _save() {
    prefs.setString(_key, jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  static String buildKey(String coffeeId, Map<String, dynamic> options) {
    final keys = options.keys.toList()..sort();
    final parts = keys.map((k) {
      final v = options[k];
      if (v is List) {
        final l = v.map((e) => '$e').toList()..sort();
        return '$k=${l.join('+')}';
      }
      return '$k=$v';
    });
    return '$coffeeId|${parts.join('|')}';
  }

  String add({
    required String coffeeId,
    required String name,
    required String image,
    required double unitPrice,
    Map<String, dynamic> options = const {},
    bool isCustom = false,
    int quantity = 1,
  }) {
    final key = buildKey(coffeeId, options);
    final idx = state.indexWhere((i) => i.key == key);
    if (idx >= 0) {
      final list = [...state];
      list[idx] = list[idx].copyWith(quantity: list[idx].quantity + quantity);
      state = list;
    } else {
      state = [
        ...state,
        CartItem(
          key: key,
          coffeeId: coffeeId,
          name: name,
          image: image,
          unitPrice: unitPrice,
          quantity: quantity,
          options: options,
          isCustom: isCustom,
        ),
      ];
    }
    _save();
    return key;
  }

  void increment(String key) {
    state = [for (final i in state) i.key == key ? i.copyWith(quantity: i.quantity + 1) : i];
    _save();
  }

  void decrement(String key) {
    final item = state.where((i) => i.key == key).firstOrNull;
    if (item == null) return;
    if (item.quantity <= 1) {
      remove(key);
      return;
    }
    state = [for (final i in state) i.key == key ? i.copyWith(quantity: i.quantity - 1) : i];
    _save();
  }

  void remove(String key) {
    state = state.where((i) => i.key != key).toList();
    _save();
  }

  void clear() {
    state = const [];
    _save();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(ref.watch(prefsProvider));
});

final lastCartKeyProvider = StateProvider<String?>((ref) => null);

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold<double>(0, (t, i) => t + i.totalPrice);
});

final customCoffeeProvider = StateProvider<CustomCoffeeOrder>((ref) => const CustomCoffeeOrder());

final deliveryAddressProvider = StateProvider<DeliveryAddress?>((ref) => null);

final tabIndexProvider = StateProvider<int>((ref) => 0);

final claimedDiscountProvider = Provider<Discount?>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  final list = ref.watch(discountsProvider).valueOrNull ?? const <Discount>[];
  if (user == null || user.claimedDiscountId.isEmpty) return null;
  final d = list.where((e) => e.id == user.claimedDiscountId).firstOrNull;
  if (d == null || d.isExpired || user.usedDiscounts.contains(d.id)) return null;
  return d;
});

class CheckoutSummary {
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final Discount? appliedDiscount;

  const CheckoutSummary({
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.appliedDiscount,
  });

  double get itemsTotal => (subtotal - discount).clamp(0, double.infinity).toDouble();
  double get total => itemsTotal + deliveryFee;
}

final checkoutSummaryProvider = Provider<CheckoutSummary>((ref) {
  final items = ref.watch(cartProvider);
  final subtotal = ref.watch(cartSubtotalProvider);
  final settings = ref.watch(appSettingsProvider);
  final d = ref.watch(claimedDiscountProvider);
  final amount = d == null ? 0.0 : d.amountFor(items);
  return CheckoutSummary(
    subtotal: subtotal,
    discount: double.parse(amount.toStringAsFixed(2)),
    deliveryFee: settings.deliveryFee,
    appliedDiscount: d,
  );
});

String money(double v) => '\$ ${v.toStringAsFixed(2)}';

String rating(double v) => v.toStringAsFixed(1).replaceAll('.', ',');
