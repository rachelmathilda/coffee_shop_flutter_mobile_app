import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../services/app_exception.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brown_field.dart';
import '../../widgets/buttons.dart';
import '../../widgets/wave_header.dart';

class EmailRecoveryScreen extends ConsumerStatefulWidget {
  final bool changeMode;
  const EmailRecoveryScreen({super.key, required this.changeMode});

  @override
  ConsumerState<EmailRecoveryScreen> createState() => _EmailRecoveryScreenState();
}

class _EmailRecoveryScreenState extends ConsumerState<EmailRecoveryScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.changeMode) {
      final user = ref.read(currentUserProvider).valueOrNull;
      _emailCtrl.text = user?.email ?? '';
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = ref.read(stringsProvider);
    final email = _emailCtrl.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      showMessage(context, t(widget.changeMode && email.isEmpty ? 'setEmailFirst' : 'invalidEmail'));
      return;
    }
    setState(() => _loading = true);
    try {
      if (!widget.changeMode) {
        await ref.read(authServiceProvider).sendPasswordResetEmail(email);
        if (!mounted) return;
        showMessage(context, t('resetLinkSent'));
        context.pop();
        return;
      }
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      if (user.email.isEmpty) {
        showMessage(context, t('setEmailFirst'));
        return;
      }
      if (email.toLowerCase() != user.email.toLowerCase()) {
        showMessage(context, t('invalidEmail'));
        return;
      }
      await ref.read(otpServiceProvider).send(uid: user.uid, email: user.email, name: user.name);
      if (!mounted) return;
      showMessage(context, t('otpSent'));
      context.push('/profile/otp');
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
          WaveHeader(title: t('recovery')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(23, 54, 23, 20),
              children: [
                Center(child: Text(t('passwordRecovery'), style: AppText.s(24, weight: FontWeight.w500, spacing: 0.5))),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    t('recoveryHint'),
                    textAlign: TextAlign.center,
                    style: AppText.s(16, color: const Color(0xFF9A9A9A), spacing: 0.5),
                  ),
                ),
                const SizedBox(height: 40),
                BrownField(
                  controller: _emailCtrl,
                  hint: '',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(23, 0, 23, 44 + bottom),
            child: PrimaryButton(label: t('save'), onTap: _submit, loading: _loading),
          ),
        ],
      ),
    );
  }
}
