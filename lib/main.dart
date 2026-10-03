import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'providers/providers.dart';
import 'router/router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const GrindApp(),
    ),
  );
}

class GrindApp extends ConsumerWidget {
  const GrindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final lang = ref.watch(languageProvider);
    ref.listen(currentUserProvider, (prev, next) {
      final user = next.valueOrNull;
      final prevUser = prev?.valueOrNull;
      if (user != null && prevUser?.uid != user.uid && user.language != lang) {
        if (ref.read(prefsProvider).containsKey('lang')) {
          ref.read(authServiceProvider).setLanguage(user.uid, lang).catchError((_) {});
        } else {
          ref.read(languageProvider.notifier).change(user.language);
        }
      }
    });
    return MaterialApp.router(
      title: 'grind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
