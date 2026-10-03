import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../services/app_exception.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brown_field.dart';
import '../../widgets/buttons.dart';
import '../../widgets/reauth.dart';
import '../../widgets/wave_header.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _pwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = ref.read(stringsProvider);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    if (_pwCtrl.text.length < 6) {
      showMessage(context, t('passwordTooShort'));
      return;
    }
    if (_pwCtrl.text != _confirmCtrl.text) {
      showMessage(context, t('passwordMismatch'));
      return;
    }
    setState(() => _loading = true);
    try {
      final otp = ref.read(otpServiceProvider);
      if (!await otp.isVerified(user.uid)) throw const AppException('otpExpired');
      if (!mounted) return;
      await withRecentLogin(context, ref, () => ref.read(authServiceProvider).updatePassword(_pwCtrl.text));
      await otp.clear(user.uid);
      if (!mounted) return;
      showMessage(context, t('passwordUpdated'));
      ref.read(tabIndexProvider.notifier).state = 3;
      context.go('/home');
    } catch (e) {
      if (mounted) showMessage(context, errorText(e, t));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          WaveHeader(title: t('newPassword')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(23, 54, 23, 20),
              children: [
                Center(child: Text(t('resetPassword'), style: AppText.s(24, weight: FontWeight.w500, spacing: 0.5))),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    t('enterNewPassword'),
                    textAlign: TextAlign.center,
                    style: AppText.s(16, color: const Color(0xFF9A9A9A), spacing: 0.5),
                  ),
                ),
                const SizedBox(height: 40),
                BrownField(
                  controller: _pwCtrl,
                  hint: t('newPasswordField'),
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  onToggle: () => setState(() => _obscure = !_obscure),
                ),
                const SizedBox(height: 24),
                BrownField(
                  controller: _confirmCtrl,
                  hint: t('confirmPassword'),
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(23, 0, 23, 44 + bottom),
            child: PrimaryButton(label: t('save'), onTap: _save, loading: _loading),
          ),
        ],
      ),
    );
  }
}
