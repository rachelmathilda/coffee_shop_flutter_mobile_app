import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

Future<T> withRecentLogin<T>(BuildContext context, WidgetRef ref, Future<T> Function() action) async {
  try {
    return await action();
  } on FirebaseAuthException catch (e) {
    if (e.code != 'requires-recent-login') rethrow;
    if (!context.mounted) rethrow;
    final service = ref.read(authServiceProvider);
    if (service.hasPasswordProvider) {
      final pw = await _askPassword(context, ref);
      if (pw == null) rethrow;
      await service.reauthenticate(pw);
    } else {
      await service.reauthenticateWithGoogle();
    }
    return await action();
  }
}

Future<String?> _askPassword(BuildContext context, WidgetRef ref) {
  final t = ref.read(stringsProvider);
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(t('reauthTitle'), style: AppText.s(18, weight: FontWeight.w600)),
      content: TextField(
        controller: ctrl,
        obscureText: true,
        autofocus: true,
        decoration: InputDecoration(hintText: t('currentPassword')),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text(t('confirm'))),
      ],
    ),
  );
}
