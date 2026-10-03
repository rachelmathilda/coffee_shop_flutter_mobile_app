import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../services/app_exception.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_wave.dart';
import '../../widgets/buttons.dart';
import 'auth_widgets.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _userCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _accept = false;
  bool _obscure = true;
  bool _loading = false;

  Future<void> _signUp() async {
    final t = ref.read(stringsProvider);
    if (_userCtrl.text.trim().isEmpty || _pwCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
      showMessage(context, t('fillAllFields'));
      return;
    }
    if (_pwCtrl.text.length < 6) {
      showMessage(context, t('passwordTooShort'));
      return;
    }
    if (_pwCtrl.text != _confirmCtrl.text) {
      showMessage(context, t('passwordMismatch'));
      return;
    }
    if (!_accept) {
      showMessage(context, t('acceptTermsFirst'));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signUp(_userCtrl.text, _pwCtrl.text);
      await ref.read(prefsProvider).setBool('remember', true);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) showMessage(context, errorText(e, t));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    final t = ref.read(stringsProvider);
    if (!_accept) {
      showMessage(context, t('acceptTermsFirst'));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      await ref.read(prefsProvider).setBool('remember', true);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) showMessage(context, errorText(e, t));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthWave(signUp: true),
            Text(t('createAccount'), style: AppText.s(32, weight: FontWeight.w700, color: AppColors.charcoal)),
            const SizedBox(height: 34),
            Center(
              child: SizedBox(
                width: 292,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NotchedField(label: t('username'), controller: _userCtrl, action: TextInputAction.next),
                    const SizedBox(height: 22),
                    NotchedField(
                      label: t('password'),
                      controller: _pwCtrl,
                      obscure: _obscure,
                      onToggleObscure: () => setState(() => _obscure = !_obscure),
                      action: TextInputAction.next,
                    ),
                    const SizedBox(height: 22),
                    NotchedField(
                      label: t('confirmPasswordLower'),
                      controller: _confirmCtrl,
                      obscure: _obscure,
                      action: TextInputAction.done,
                      onSubmitted: (_) => _signUp(),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RingCheck(
                        value: _accept,
                        label: t('acceptTerms'),
                        onChanged: (v) => setState(() => _accept = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            DarkPillButton(label: t('signUp'), onTap: _signUp, loading: _loading),
            const SizedBox(height: 24),
            Text(t('or'), style: AppText.s(16, weight: FontWeight.w300)),
            const SizedBox(height: 24),
            GoogleButton(label: t('signUpWithGoogle'), onTap: _loading ? null : _google),
            const SizedBox(height: 90),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t('haveAccount'), style: AppText.s(15, weight: FontWeight.w300)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.go('/auth/sign-in'),
                  child: Text(t('signIn'), style: AppText.s(15, weight: FontWeight.w600, color: const Color(0xFF6B747C))),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
