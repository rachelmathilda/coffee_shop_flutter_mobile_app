import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/providers.dart';
import '../../services/app_exception.dart';
import '../../widgets/avatar.dart';
import '../../widgets/brown_field.dart';
import '../../widgets/buttons.dart';
import '../../widgets/reauth.dart';
import '../../widgets/wave_header.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _newAvatar;
  bool _loading = false;
  bool _filled = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 320,
      maxHeight: 320,
      imageQuality: 70,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _newAvatar = 'data:image/jpeg;base64,${base64Encode(bytes)}');
  }

  Future<void> _save() async {
    final t = ref.read(stringsProvider);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    if (_nameCtrl.text.trim().isEmpty || _userCtrl.text.trim().isEmpty) {
      showMessage(context, t('fillAllFields'));
      return;
    }
    final email = _emailCtrl.text.trim();
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      showMessage(context, t('invalidEmail'));
      return;
    }
    setState(() => _loading = true);
    try {
      final sent = await withRecentLogin(
        context,
        ref,
        () => ref.read(authServiceProvider).updateProfile(
              current: user,
              name: _nameCtrl.text,
              username: _userCtrl.text,
              email: email,
              avatar: _newAvatar,
            ),
      );
      if (!mounted) return;
      showMessage(context, sent ? t('verificationSent') : t('profileUpdated'));
      context.pop();
    } catch (e) {
      if (mounted) showMessage(context, errorText(e, t));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user != null && !_filled) {
      _filled = true;
      _nameCtrl.text = user.name;
      _userCtrl.text = user.username;
      _emailCtrl.text = user.pendingEmail.isNotEmpty ? user.pendingEmail : user.email;
    }
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          WaveHeader(title: t('editProfile')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(23, 10, 23, 20),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pick,
                    child: SizedBox(
                      width: 124,
                      height: 124,
                      child: Stack(
                        children: [
                          Avatar(data: _newAvatar ?? user?.avatar ?? '', size: 120),
                          Positioned(
                            right: 0,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.photo_camera_outlined, size: 26, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                BrownField(controller: _nameCtrl, hint: t('name')),
                const SizedBox(height: 32),
                BrownField(controller: _userCtrl, hint: 'Username'),
                const SizedBox(height: 32),
                BrownField(controller: _emailCtrl, hint: t('email'), keyboardType: TextInputType.emailAddress),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(23, 0, 23, 36 + bottom),
            child: PrimaryButton(label: t('save'), onTap: _save, loading: _loading),
          ),
        ],
      ),
    );
  }
}
