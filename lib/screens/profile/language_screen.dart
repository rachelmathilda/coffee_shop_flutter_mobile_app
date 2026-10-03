import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/flag.dart';
import '../../widgets/wave_header.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  late String _selected;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(languageProvider);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    await ref.read(languageProvider.notifier).change(_selected);
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      try {
        await ref.read(authServiceProvider).setLanguage(user.uid, _selected);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() => _loading = false);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          WaveHeader(title: t('language')),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(23, 6, 23, 20),
              itemCount: supportedLanguages.length,
              itemBuilder: (_, i) {
                final code = supportedLanguages[i];
                final selected = code == _selected;
                return Material(
                  color: i.isEven ? AppColors.beige : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selected = code),
                    child: SizedBox(
                      height: 83,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 29, right: 28),
                        child: Row(
                          children: [
                            FlagIcon(code: code),
                            const SizedBox(width: 24),
                            Expanded(child: Text(languageNames[code]!, style: AppText.s(16, spacing: 0.3))),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.textBrown, width: 1.6),
                              ),
                              alignment: Alignment.center,
                              child: selected
                                  ? Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.textBrown,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(23, 0, 23, 30 + bottom),
            child: PrimaryButton(label: t('save'), onTap: _save, loading: _loading),
          ),
        ],
      ),
    );
  }
}
