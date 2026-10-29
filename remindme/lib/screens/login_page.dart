import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _selectedRole;

  final List<String> _roles = ['Parent', 'Independent', 'Child'];

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

  String? _validateRole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your role';
    }
    return null;
  }
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              user: userCredential.user,
              role: _selectedRole ?? 'User',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed.';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password provided.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credentials. Please check your email and password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is formatted incorrectly.';
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred: ${e.toString()}');
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
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
                      labelText: 'Email / Username',
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
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: "I’m a...",
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: _roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    validator: _validateRole,
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