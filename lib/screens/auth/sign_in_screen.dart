import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../services/app_exception.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_wave.dart';
import '../../widgets/buttons.dart';
import 'auth_widgets.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _remember = true;
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _remember = ref.read(prefsProvider).getBool('remember') ?? true;
  }

  Future<void> _afterLogin() async {
    await ref.read(prefsProvider).setBool('remember', _remember);
    if (mounted) context.go('/home');
  }

  Future<void> _signIn() async {
    final t = ref.read(stringsProvider);
    if (_idCtrl.text.trim().isEmpty || _pwCtrl.text.isEmpty) {
      showMessage(context, t('fillAllFields'));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signIn(_idCtrl.text, _pwCtrl.text);
      await _afterLogin();
    } catch (e) {
      if (mounted) showMessage(context, errorText(e, t));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    final t = ref.read(stringsProvider);
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      await _afterLogin();
    } catch (e) {
      if (mounted) showMessage(context, errorText(e, t));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
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
            const AuthWave(),
            const SizedBox(height: 22),
            Text(t('welcomeBack'), style: AppText.s(32, weight: FontWeight.w700, color: AppColors.charcoal)),
            const SizedBox(height: 34),
            Center(
              child: SizedBox(
                width: 292,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NotchedField(
                      label: t('username'),
                      controller: _idCtrl,
                      action: TextInputAction.next,
                    ),
                    const SizedBox(height: 22),
                    NotchedField(
                      label: t('password'),
                      controller: _pwCtrl,
                      obscure: _obscure,
                      onToggleObscure: () => setState(() => _obscure = !_obscure),
                      action: TextInputAction.done,
                      onSubmitted: (_) => _signIn(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RingCheck(
                          value: _remember,
                          label: t('rememberMe'),
                          onChanged: (v) => setState(() => _remember = v),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.push('/auth/recovery'),
                          child: Text(t('forgotPassword'), style: AppText.s(12, weight: FontWeight.w300)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            DarkPillButton(label: t('signIn'), onTap: _signIn, loading: _loading),
            const SizedBox(height: 24),
            Text(t('or'), style: AppText.s(16, weight: FontWeight.w300)),
            const SizedBox(height: 24),
            GoogleButton(label: t('signUpWithGoogle'), onTap: _loading ? null : _google),
            const SizedBox(height: 90),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t('noAccount'), style: AppText.s(15, weight: FontWeight.w300)),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => context.go('/auth/sign-up'),
                  child: Text(t('signUp'), style: AppText.s(15, weight: FontWeight.w600, color: const Color(0xFF6B747C))),
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
