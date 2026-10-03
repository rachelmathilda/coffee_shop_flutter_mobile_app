import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/strings.dart';

class AppException implements Exception {
  final String code;
  const AppException(this.code);

  @override
  String toString() => code;
}

String errorText(Object e, Strings t) {
  if (e is AppException) return t(e.code);
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-login-credentials':
        return t('wrongCredential');
      case 'email-already-in-use':
        return t('emailInUse');
      case 'weak-password':
        return t('weakPassword');
      case 'invalid-email':
        return t('invalidEmail');
      case 'network-request-failed':
        return t('networkError');
      default:
        return e.message ?? t('genericError');
    }
  }
  if (e is FirebaseException) {
    if (e.code == 'unavailable') return t('networkError');
    return e.message ?? t('genericError');
  }
  return t('genericError');
}
