import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth_service.dart';
import 'home_page.dart';
import 'parent_home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.accountDeleted = false});

  final bool accountDeleted;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _demoEmail = 'user@example.com';
  static const _demoPassword = 'example';

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email field cannot be empty';
    }

    final trimmedEmail = value.trim();

    // Check for spaces anywhere in email
    if (trimmedEmail.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    // Check for @ symbol
    if (!trimmedEmail.contains('@')) {
      return 'Email must contain an @ symbol';
    }

    // Check for multiple @ symbols
    final atParts = trimmedEmail.split('@');
    if (atParts.length > 2) {
      return 'Email cannot contain multiple @ symbols';
    }

    final username = atParts[0];
    final domain = atParts[1];

    // Missing username before @
    if (username.isEmpty) {
      return 'Missing username before @ symbol';
    }

    // Missing domain after @
    if (domain.isEmpty) {
      return 'Missing domain after @ symbol';
    }

    // Domain missing extension like .com or .org
    if (!domain.contains('.')) {
      return 'Missing domain extension like .com or .org';
    }

    // Domain ends with a period
    if (domain.endsWith('.')) {
      return 'Domain cannot end with a period';
    }

    final domainParts = domain.split('.');
    final extension = domainParts.last;

    // Missing org or com after .
    if (extension.isEmpty) {
      return 'Missing domain extension after . (e.g. .com or .org)';
    }

    if (extension.length < 2) {
      return 'Domain extension must be at least 2 letters (e.g., com, org)';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password field cannot be empty';
    }

    if (_emailController.text.trim().toLowerCase() == _demoEmail &&
        value == _demoPassword) {
      return null;
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  void _navigateToHome({
    required User user,
    required String name,
    required String role,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(user: user, name: name, role: role),
      ),
    );
  }

  void _navigateToDemoHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ParentHomePage(
          name: 'Falis',
          demoMode: true,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      if (email.toLowerCase() == _demoEmail &&
          _passwordController.text == _demoPassword) {
        if (mounted) {
          _navigateToDemoHome();
        }
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email,
            password: _passwordController.text,
          );

      final user = userCredential.user;
      if (user == null) {
        throw StateError('Authentication returned no user.');
      }

      final profile = await AuthService().getMyProfile();
      if (profile == null) {
        throw StateError('Your account profile could not be found.');
      }

      final accountType = profile['role'];
      if (accountType is! String) {
        throw StateError('Your account type is missing.');
      }

      final role = accountType.toLowerCase();
      if (role != 'parent' && role != 'independent') {
        throw StateError('Your account type is not supported.');
      }

      final profileName = profile['name'];
      final name = profileName is String && profileName.trim().isNotEmpty
          ? profileName.trim()
          : user.displayName ?? user.email?.split('@').first ?? 'there';

      if (!mounted) return;

      _navigateToHome(user: user, name: name, role: role);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed.';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password provided.';
      } else if (e.code == 'invalid-credential') {
        errorMessage =
            'Invalid credentials. Please check your email and password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is formatted incorrectly.';
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      final message = e is StateError
          ? e.message.toString()
          : 'An unexpected error occurred: ${e.toString()}';
      _showErrorDialog(message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.accountDeleted) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E7D32),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Account deleted successfully.',
                              style: TextStyle(color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Text(
                    'Welcome back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please sign in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'user@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Log In',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don’t have an account? "),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
                              },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
