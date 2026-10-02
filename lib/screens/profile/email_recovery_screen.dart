import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class EmailRecoveryScreen extends ConsumerStatefulWidget {
  const EmailRecoveryScreen({super.key});

  @override
  ConsumerState<EmailRecoveryScreen> createState() =>
      _EmailRecoveryScreenState();
}

class _EmailRecoveryScreenState extends ConsumerState<EmailRecoveryScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  Future<void> _sendResetEmail() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(_emailCtrl.text.trim());
      if (mounted) {
        setState(() => _sent = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                ClipPath(
                  clipper: _WC(0),
                  child: Container(color: const Color(0xFF3D3D3D), height: 200),
                ),
                ClipPath(
                  clipper: _WC(20),
                  child: Container(color: AppColors.primary, height: 180),
                ),
                ClipPath(
                  clipper: _WC(40),
                  child: Container(color: AppColors.secondary, height: 160),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Forgot Password',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sent
                        ? 'reset link sent, check your inbox and follow the link to set a new password'
                        : 'enter your email and we will send you a link to reset your password',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_sent) ...[
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'email'),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _loading ? null : _sendResetEmail,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('send reset link'),
                    ),
                  ] else
                    ElevatedButton(
                      onPressed: () => context.go('/auth/sign-in'),
                      child: const Text('back to sign in'),
                    ),
                  const SizedBox(height: 20),
                  if (!_sent)
                    Center(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          'back to sign in',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WC extends CustomClipper<Path> {
  final double off;
  const _WC(this.off);
  @override
  Path getClip(Size s) {
    return Path()
      ..lineTo(0, s.height - 30 - off)
      ..quadraticBezierTo(
        s.width * 0.3,
        s.height - off,
        s.width * 0.6,
        s.height - 20 - off,
      )
      ..quadraticBezierTo(
        s.width * 0.85,
        s.height - 40 - off,
        s.width,
        s.height - 10 - off,
      )
      ..lineTo(s.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(_WC o) => false;
}
