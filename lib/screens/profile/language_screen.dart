import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_header.dart';

class _Language {
  final String name;
  final String flag;
  const _Language(this.name, this.flag);
}

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'English';

  final _languages = const [
    _Language('Bahasa Indonesia', '🇮🇩'),
    _Language('Brazilian Portuguese', '🇧🇷'),
    _Language('English', '🇬🇧'),
    _Language('French', '🇫🇷'),
    _Language('German', '🇩🇪'),
    _Language('Hangul', '🇰🇷'),
    _Language('Hindi', '🇮🇳'),
    _Language('Italian', '🇮🇹'),
    _Language('Japanese', '🇯🇵'),
    _Language('Spanish', '🇪🇸'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const WaveHeader(title: 'Language'),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final lang = _languages[i];
                final active = lang.name == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = lang.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.secondary.withOpacity(0.5)
                          : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active ? AppColors.primary : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang.flag, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            lang.name,
                            style: TextStyle(
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 14,
                              color: active
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.textLight,
                              width: 1.5,
                            ),
                          ),
                          child: active
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
