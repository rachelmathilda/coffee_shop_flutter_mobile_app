import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_header.dart';

class EmailRecoveryScreen extends ConsumerStatefulWidget {
  const EmailRecoveryScreen({super.key});

  @override
  ConsumerState<EmailRecoveryScreen> createState() =>
      _EmailRecoveryScreenState();
}

class _EmailRecoveryScreenState extends ConsumerState<EmailRecoveryScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _send() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(_emailCtrl.text.trim());
      if (mounted) context.push('/auth/otp');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
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
          const WaveHeader(title: 'Recovery'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password recovery',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your email to recover your password',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                      ),
                      hintText: 'Email',
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _loading ? null : _send,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save'),
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
