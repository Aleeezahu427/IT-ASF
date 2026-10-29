import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              user: currentUser,
              role: 'User',
            ),
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('Firebase auth check note: $e');
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.notifications_active_rounded,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
            const SizedBox(height: 32),

            const CircularProgressIndicator(
              color: Color(0xFF4B83EB),
            ),
          ],
        ),
      ),
    );
  }
}