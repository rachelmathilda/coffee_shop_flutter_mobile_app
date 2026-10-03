import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../services/app_exception.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/wave_header.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _ctrls = List.generate(4, (_) => TextEditingController());
  final _nodes = List.generate(4, (_) => FocusNode());
  bool _verifying = false;
  bool _resending = false;

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    final t = ref.read(stringsProvider);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    if (_code.length != 4) {
      showMessage(context, t('otpInvalid'));
      return;
    }
    setState(() => _verifying = true);
    try {
      await ref.read(otpServiceProvider).verify(uid: user.uid, code: _code);
      if (mounted) context.pushReplacement('/profile/new-password');
    } catch (e) {
      if (mounted) showMessage(context, errorText(e, t));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    final t = ref.read(stringsProvider);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    setState(() => _resending = true);
    try {
      await ref.read(otpServiceProvider).send(uid: user.uid, email: user.email, name: user.name);
      for (final c in _ctrls) {
        c.clear();
      }
      _nodes.first.requestFocus();
      if (mounted) showMessage(context, t('otpSent'));
    } catch (e) {
      if (mounted) showMessage(context, errorText(e, t));
    } finally {
      if (mounted) setState(() => _resending = false);
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
          WaveHeader(title: t('otp')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(23, 54, 23, 20),
              children: [
                Center(child: Text(t('checkYourEmail'), style: AppText.s(24, weight: FontWeight.w500, spacing: 0.5))),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    t('codeSent'),
                    textAlign: TextAlign.center,
                    style: AppText.s(16, color: const Color(0xFF9A9A9A), spacing: 0.5),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (i) {
                    return SizedBox(
                      width: 70,
                      height: 70,
                      child: TextField(
                        controller: _ctrls[i],
                        focusNode: _nodes[i],
                        autofocus: i == 0,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: AppText.s(28, weight: FontWeight.w500),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.textBrown),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.brown, width: 1.6),
                          ),
                        ),
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 3) _nodes[i + 1].requestFocus();
                          if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
                          if (_code.length == 4) _verify();
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: OutlineButtonX(label: t('resend'), onTap: _resend, loading: _resending),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.fromLTRB(23, 0, 23, 44 + bottom),
            child: PrimaryButton(label: t('verify'), onTap: _verify, loading: _verifying),
          ),
        ],
      ),
    );
  }
}
