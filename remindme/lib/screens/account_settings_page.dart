import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth_service.dart';
import 'login_page.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key, required this.name});

  final String name;

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  static const _teal = Color(0xFF16796E);

  final _nameFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
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

  String _capitalizeFirstLetter(String value) {
    final trimmed = value.trim();
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  Future<void> _saveName() async {
    if (!_nameFormKey.currentState!.validate()) return;

    final name = _capitalizeFirstLetter(_nameController.text);
    setState(() => _isBusy = true);
    try {
      await AuthService().updateName(name: name);
      if (!mounted) return;
      Navigator.of(context).pop(name);
    } on FirebaseAuthException catch (error) {
      _showError('Could not update your name', error);
    } catch (error) {
      _showError('Could not update your name', error);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<List<String>?> _requestPasswordChange() {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('Change password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
                validator: (value) =>
                    _validateRequired(value, 'Current password'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
                validator: _validatePassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                ),
                validator: (value) {
                  final requiredError = _validateRequired(
                    value,
                    'Confirm password',
                  );
                  if (requiredError != null) return requiredError;
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext, [
                currentPasswordController.text,
                newPasswordController.text,
              ]);
            },
            child: const Text('Update password'),
          ),
        ],
      ),
    ).whenComplete(() {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    });
  }

  Future<String?> _requestCurrentPassword() {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm your password'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Current password'),
            validator: (value) => _validateRequired(value, 'Password'),
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, controller.text);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext, controller.text);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _changePassword() async {
    if (_isBusy) return;
    final values = await _requestPasswordChange();
    if (values == null) return;

    setState(() => _isBusy = true);
    try {
      await AuthService().changePassword(
        currentPassword: values[0],
        newPassword: values[1],
      );
      if (!mounted) return;
      _showMessage('Password updated.');
    } on FirebaseAuthException catch (error) {
      _showError('Could not update your password', error);
    } catch (error) {
      _showError('Could not update your password', error);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _deleteAccount() async {
    if (_isBusy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account, profile, and child profiles. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final password = await _requestCurrentPassword();
    if (password == null) return;

    setState(() => _isBusy = true);
    try {
      await AuthService().deleteAccount(currentPassword: password);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LoginPage(accountDeleted: true),
        ),
        (_) => false,
      );
    } on FirebaseAuthException catch (error) {
      _showError('Could not delete your account', error);
    } catch (error) {
      _showError('Could not delete your account', error);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showError(String action, Object error) {
    final message = error is FirebaseAuthException
        ? switch (error.code) {
            'wrong-password' ||
            'invalid-credential' => 'Current password is incorrect.',
            'weak-password' => 'Choose a stronger password.',
            'requires-recent-login' =>
              'Please sign in again before trying this action.',
            'network-request-failed' =>
              'Check your internet connection and try again.',
            _ => error.message ?? error.code,
          }
        : '$action: $error';
    _showMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F7F6),
        title: const Text('Account settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _nameFormKey,
              child: TextFormField(
                controller: _nameController,
                enabled: !_isBusy,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateRequired(value, 'Name'),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isBusy ? null : _saveName,
              style: FilledButton.styleFrom(backgroundColor: _teal),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save name'),
            ),
            const Divider(height: 40),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change password'),
              subtitle: const Text('You will need your current password.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _isBusy ? null : _changePassword,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _isBusy ? null : _deleteAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete account'),
            ),
            if (_isBusy) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
