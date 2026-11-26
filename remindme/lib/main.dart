import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app_theme.dart';
import 'firebase_options.dart';
import 'screens/account_type_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppThemeSettings.load();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppPalette>(
      valueListenable: AppThemeSettings.selectedPalette,
      builder: (context, palette, _) => MaterialApp(
        title: 'RemindMe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: palette.seedColor),
          useMaterial3: true,
        ),
        builder: (context, child) => LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 500) return child!;

            return ColoredBox(
              color: const Color(0xFFE4E5EE),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Container(
                      width: 390,
                      height: 844,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            size: const Size(374, 828),
                            padding: EdgeInsets.zero,
                            viewPadding: EdgeInsets.zero,
                            viewInsets: EdgeInsets.zero,
                          ),
                          child: child!,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        home: const AccountTypeSelectionPage(),
      ),
    );
  }
}
