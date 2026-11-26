import 'package:flutter/material.dart';

import 'child_login_page.dart';
import 'login_page.dart';

class AccountTypeSelectionPage extends StatelessWidget {
  const AccountTypeSelectionPage({super.key, this.accountDeleted = false});

  final bool accountDeleted;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (accountDeleted) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
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
                    const SizedBox(height: 24),
                  ],
                  Icon(
                    Icons.notifications_active_rounded,
                    size: 64,
                    color: primary,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to RemindMe',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose how you want to sign in',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ChildLoginPage(),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    icon: const Icon(Icons.child_care),
                    label: const Text('I’m a kid'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginPage(),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    icon: const Icon(Icons.family_restroom),
                    label: const Text('Parent / Independent'),
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
