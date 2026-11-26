import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const _requirementGreen = Color(0xFF2E7D32);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedAccountType;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final requiredError = _validateRequired(value, 'Email');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final requiredError = _validateRequired(value, 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < 8) return 'Use at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Include at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Include at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final requiredError = _validateRequired(value, 'Confirm password');
    if (requiredError != null) return requiredError;
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final accountType = _selectedAccountType;
    if (accountType == null) return;

    setState(() => _isLoading = true);
    try {
      final user = await AuthService().registerAccount(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        accountType: accountType,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => HomePage(user: user, role: accountType),
        ),
        (_) => false,
      );
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'email-already-in-use' => 'An account already exists for this email.',
        'invalid-email' => 'Enter a valid email address.',
        'weak-password' => 'Choose a stronger password.',
        'network-request-failed' =>
          'Check your internet connection and try again.',
        _ => error.message ?? 'Could not create your account.',
      };
      _showError(message);
    } catch (error) {
      _showError('Could not create your account: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F7F6),
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Icon(Icons.person_add_alt_1, size: 48, color: primary),
              const SizedBox(height: 12),
              const Text(
                'Join RemindMe',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create an account to get started',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateRequired(value, 'Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                enabled: !_isLoading,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                validator: _validatePassword,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              _buildPasswordRequirement(
                'At least 8 characters',
                _passwordController.text.length >= 8,
              ),
              _buildPasswordRequirement(
                'At least one uppercase letter',
                _passwordController.text.contains(RegExp(r'[A-Z]')),
              ),
              _buildPasswordRequirement(
                'At least one number',
                _passwordController.text.contains(RegExp(r'[0-9]')),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                enabled: !_isLoading,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedAccountType,
                decoration: const InputDecoration(
                  labelText: 'Account type',
                  prefixIcon: Icon(Icons.people_outline),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'parent', child: Text('Parent')),
                  DropdownMenuItem(
                    value: 'independent',
                    child: Text('Independent'),
                  ),
                ],
                onChanged: _isLoading
                    ? null
                    : (value) => setState(() => _selectedAccountType = value),
                validator: (value) =>
                    value == null ? 'Select an account type' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _register,
                  style: FilledButton.styleFrom(backgroundColor: primary),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create account',
                          style: TextStyle(fontSize: 17),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    final color = isMet ? _requirementGreen : Colors.black54;
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
