import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import 'app_exception.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final _usernameRe = RegExp(r'^[a-z0-9_]{3,20}$');

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  static bool isSyntheticEmail(String? email) =>
      email == null || email.isEmpty || email.endsWith('@${AppConfig.syntheticEmailDomain}');

  DocumentReference<Map<String, dynamic>> userRef(String uid) =>
      _db.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _usernameRef(String username) =>
      _db.collection('usernames').doc(username);

  Future<void> signIn(String identifier, String password) async {
    final id = identifier.trim();
    if (id.contains('@')) {
      await _auth.signInWithEmailAndPassword(email: id, password: password);
      await syncAccount();
      return;
    }
    final snap = await _usernameRef(id.toLowerCase()).get();
    if (!snap.exists) {
      throw const AppException('wrongCredential');
    }
    final data = snap.data()!;
    final email = (data['email'] ?? '') as String;
    final pending = (data['pendingEmail'] ?? '') as String;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      final retry = pending.isNotEmpty &&
          (e.code == 'invalid-credential' ||
              e.code == 'user-not-found' ||
              e.code == 'wrong-password' ||
              e.code == 'invalid-login-credentials');
      if (!retry) rethrow;
      await _auth.signInWithEmailAndPassword(email: pending, password: password);
    }
    await syncAccount();
  }

  Future<void> signUp(String username, String password) async {
    final u = username.trim().toLowerCase();
    if (!_usernameRe.hasMatch(u)) throw const AppException('usernameInvalid');
    final existing = await _usernameRef(u).get();
    if (existing.exists) throw const AppException('usernameTaken');
    final email = '$u@${AppConfig.syntheticEmailDomain}';
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user!;
    try {
      await _reserveAndCreate(user.uid, u, email, displayName: u);
    } catch (e) {
      await user.delete();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    provider.addScope('email');
    provider.setCustomParameters({'prompt': 'select_account'});
    final cred = await _auth.signInWithProvider(provider);
    final user = cred.user;
    if (user == null) throw const AppException('genericError');
    final doc = await userRef(user.uid).get();
    if (!doc.exists) {
      final base = (user.email ?? 'user')
          .split('@')
          .first
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
      final rnd = Random.secure();
      String candidate = base.length >= 3 ? base : 'user$base';
      if (candidate.length > 15) candidate = candidate.substring(0, 15);
      for (var i = 0; i < 6; i++) {
        final name = i == 0 ? candidate : '${candidate}_${rnd.nextInt(9000) + 1000}';
        try {
          await _reserveAndCreate(
            user.uid,
            name,
            user.email ?? '',
            displayName: user.displayName ?? name,
          );
          return;
        } on AppException catch (e) {
          if (e.code != 'usernameTaken') rethrow;
        }
      }
      throw const AppException('genericError');
    }
    await syncAccount();
  }

  Future<void> _reserveAndCreate(
    String uid,
    String username,
    String email, {
    required String displayName,
  }) async {
    await _db.runTransaction((tx) async {
      final nameRef = _usernameRef(username);
      final nameSnap = await tx.get(nameRef);
      if (nameSnap.exists) throw const AppException('usernameTaken');
      tx.set(nameRef, {'uid': uid, 'email': email, 'pendingEmail': ''});
      tx.set(userRef(uid), {
        'name': displayName,
        'username': username,
        'email': isSyntheticEmail(email) ? '' : email,
        'authEmail': email,
        'pendingEmail': '',
        'avatar': '',
        'points': 0,
        'language': 'en',
        'claimedDiscountId': '',
        'usedDiscounts': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> syncAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.reload();
    final fresh = _auth.currentUser;
    if (fresh == null) return;
    final authEmail = fresh.email ?? '';
    final snap = await userRef(fresh.uid).get();
    if (!snap.exists) return;
    final data = snap.data()!;
    if ((data['authEmail'] ?? '') == authEmail) return;
    final username = (data['username'] ?? '') as String;
    final pending = (data['pendingEmail'] ?? '') as String;
    final batch = _db.batch();
    batch.update(userRef(fresh.uid), {
      'authEmail': authEmail,
      'email': isSyntheticEmail(authEmail) ? '' : authEmail,
      'pendingEmail': pending == authEmail ? '' : pending,
    });
    if (username.isNotEmpty) {
      batch.update(_usernameRef(username), {
        'email': authEmail,
        'pendingEmail': pending == authEmail ? '' : pending,
      });
    }
    await batch.commit();
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(email: user.email!, password: password);
    await user.reauthenticateWithCredential(cred);
  }

  bool get hasPasswordProvider =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'password') ?? false;

  Future<void> reauthenticateWithGoogle() async {
    await _auth.currentUser!.reauthenticateWithProvider(GoogleAuthProvider());
  }

  Future<void> updatePassword(String newPassword) =>
      _auth.currentUser!.updatePassword(newPassword);

  Future<bool> updateProfile({
    required AppUser current,
    required String name,
    required String username,
    required String email,
    String? avatar,
  }) async {
    final uid = current.uid;
    final newUsername = username.trim().toLowerCase();
    if (!_usernameRe.hasMatch(newUsername)) throw const AppException('usernameInvalid');
    final authEmail = _auth.currentUser?.email ?? '';

    if (newUsername != current.username) {
      await _db.runTransaction((tx) async {
        final newRef = _usernameRef(newUsername);
        final snap = await tx.get(newRef);
        if (snap.exists) throw const AppException('usernameTaken');
        tx.set(newRef, {
          'uid': uid,
          'email': authEmail,
          'pendingEmail': current.pendingEmail,
        });
        if (current.username.isNotEmpty) tx.delete(_usernameRef(current.username));
        tx.update(userRef(uid), {'username': newUsername});
      });
    }

    final update = <String, dynamic>{'name': name.trim()};
    if (avatar != null) update['avatar'] = avatar;
    await userRef(uid).update(update);

    final newEmail = email.trim();
    bool verificationSent = false;
    if (newEmail.isNotEmpty && newEmail != authEmail && newEmail != current.email) {
      await _auth.currentUser!.verifyBeforeUpdateEmail(newEmail);
      final batch = _db.batch();
      batch.update(userRef(uid), {'pendingEmail': newEmail});
      batch.update(_usernameRef(newUsername), {'pendingEmail': newEmail});
      await batch.commit();
      verificationSent = true;
    }
    return verificationSent;
  }

  Future<void> setLanguage(String uid, String lang) =>
      userRef(uid).update({'language': lang});

  Future<void> claimDiscount(String uid, String discountId) =>
      userRef(uid).update({'claimedDiscountId': discountId});

  Future<String> placeOrder({
    required String uid,
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required String discountId,
    required double deliveryFee,
    required double total,
    required DeliveryAddress address,
    required Map<String, dynamic> payment,
    required String status,
    required int pointsEarned,
  }) async {
    final orderRef = _db.collection('orders').doc();
    final batch = _db.batch();
    batch.set(orderRef, {
      'userId': uid,
      'items': items
          .map((i) => {
                'coffeeId': i.coffeeId,
                'name': i.name,
                'image': i.image,
                'unitPrice': i.unitPrice,
                'quantity': i.quantity,
                'options': i.options,
                'isCustom': i.isCustom,
              })
          .toList(),
      'subtotal': subtotal,
      'discount': discount,
      'discountId': discountId,
      'deliveryFee': deliveryFee,
      'total': total,
      'address': address.toMap(),
      'payment': payment,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final userUpdate = <String, dynamic>{
      'points': FieldValue.increment(pointsEarned),
    };
    if (discountId.isNotEmpty) {
      userUpdate['claimedDiscountId'] = '';
      userUpdate['usedDiscounts'] = FieldValue.arrayUnion([discountId]);
    }
    batch.update(userRef(uid), userUpdate);
    await batch.commit();
    return orderRef.id;
  }
}
