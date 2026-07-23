import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/preferences_service.dart';
import 'core/utils/snackbar_utils.dart';
import 'core/services/connectivity_service.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  try {

    await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

    debugPrint('Firebase initialized successfully');

  } catch (e) {

    debugPrint(
  'Firebase initialization failed.',
    );

    debugPrint(e.toString());
  }

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const SmartFinanceApp(),
    ),
  );
}

class SmartFinanceApp extends ConsumerWidget {

  const SmartFinanceApp({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    // Initialize connectivity listener
    ref.watch(connectivityProvider);

    final router =
        ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Smart Finance AI',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}