import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = false;
  bool _loading = false;
  bool _obscure = true;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(authServiceProvider)
          .signIn(_usernameCtrl.text.trim(), _passwordCtrl.text);
      if (mounted) context.go('/catalog');
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
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _WaveHeaderAuth(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'username',
                      labelText: 'username',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'password',
                      labelText: 'password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            Icon(
                              _rememberMe
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'remember me',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/auth/recovery'),
                        child: const Text(
                          'forgot password?',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _loading ? null : _signIn,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('sign up'),
                  ),
                  const SizedBox(height: 20),
                  const _OrDivider(),
                  const SizedBox(height: 16),
                  _SocialButton(
                    icon: Icons.g_mobiledata,
                    label: 'sign up with google',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    icon: Icons.apple,
                    label: 'sign up with apple',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/auth/sign-up'),
                      child: RichText(
                        text: const TextSpan(
                          text: "don't have an account yet? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: 'sign in',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

class _WaveHeaderAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

class _WC extends CustomClipper<Path> {
  final double off;
  const _WC(this.off);
  @override
  Path getClip(Size s) {
    final p = Path()
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
    return p;
  }

  @override
  bool shouldReclip(_WC o) => false;
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: AppColors.textSecondary)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0D0C0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
