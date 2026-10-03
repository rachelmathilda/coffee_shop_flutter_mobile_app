import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'app_exception.dart';

class OtpService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _ref(String uid) =>
      _db.collection('users').doc(uid).collection('private').doc('otp');

  String _hash(String uid, String code) =>
      sha256.convert(utf8.encode('$uid:$code')).toString();

  Future<void> send({required String uid, required String email, required String name}) async {
    if (!AppConfig.emailJsConfigured) throw const AppException('emailNotConfigured');
    final code = (Random.secure().nextInt(9000) + 1000).toString();
    await _ref(uid).set({
      'hash': _hash(uid, code),
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
      'attempts': 0,
      'verified': false,
    });
    final body = <String, dynamic>{
      'service_id': AppConfig.emailJsServiceId,
      'template_id': AppConfig.emailJsTemplateId,
      'user_id': AppConfig.emailJsPublicKey,
      'template_params': {
        'to_email': email,
        'to_name': name,
        'otp_code': code,
      },
    };
    if (AppConfig.emailJsPrivateKey.isNotEmpty) {
      body['accessToken'] = AppConfig.emailJsPrivateKey;
    }
    final res = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) throw const AppException('genericError');
  }

  Future<void> verify({required String uid, required String code}) async {
    final snap = await _ref(uid).get();
    final data = snap.data();
    if (data == null) throw const AppException('otpExpired');
    final expires = (data['expiresAt'] as Timestamp).toDate();
    final attempts = ((data['attempts'] ?? 0) as num).toInt();
    if (DateTime.now().isAfter(expires) || attempts >= 5) {
      await _ref(uid).delete();
      throw const AppException('otpExpired');
    }
    if (data['hash'] != _hash(uid, code)) {
      await _ref(uid).update({'attempts': attempts + 1});
      throw const AppException('otpInvalid');
    }
    await _ref(uid).update({'verified': true});
  }

  Future<bool> isVerified(String uid) async {
    final data = (await _ref(uid).get()).data();
    if (data == null) return false;
    final expires = (data['expiresAt'] as Timestamp).toDate();
    return data['verified'] == true && DateTime.now().isBefore(expires);
  }

  Future<void> clear(String uid) => _ref(uid).delete();
}
