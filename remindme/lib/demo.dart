import 'package:flutter/material.dart';
import 'screens/child_home_page.dart';

// Opens the child homepage without Firebase login.
void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RemindMe — Child Homepage Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6554CF),
        ),
        useMaterial3: true,
      ),
      home: const ChildHomePage(
        name: 'Alex',
        demoMode: true,
      ),
    );
  }
}
