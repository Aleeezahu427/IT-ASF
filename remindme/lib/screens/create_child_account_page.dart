import 'package:flutter/material.dart';

class CreateChildAccountPage extends StatefulWidget {
  const CreateChildAccountPage({super.key});

  @override
  State<CreateChildAccountPage> createState() => _CreateChildAccountPageState();
}

class _CreateChildAccountPageState extends State<CreateChildAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
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

  void _showFirebaseNotice() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firebase setup is still needed'),
        content: const Text(
          'This form is ready, but the child account has not been saved. '
          'We still need to connect unique usernames and child passwords '
          'to Firebase authentication.',
        ),
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
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F7F6),
        title: const Text('Create child account'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Child details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a name and username your child can use to sign in.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Child’s full name',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateRequired(value, 'Full name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  helperText: 'This will be the child’s unique sign-in ID.',
                  prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateRequired(value, 'Username'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
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
                obscureText: _obscureConfirmPassword,
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
                validator: (value) {
                  final requiredError = _validateRequired(
                    value,
                    'Confirm password',
                  );
                  if (requiredError != null) return requiredError;
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showFirebaseNotice();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    final color = isMet ? const Color(0xFF2E7D32) : Colors.black54;
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
