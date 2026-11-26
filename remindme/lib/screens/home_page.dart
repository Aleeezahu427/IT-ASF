import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'account_settings_page.dart';
import 'account_type_selection_page.dart';
import 'child_home_page.dart';
import 'parent_home_page.dart';

class HomePage extends StatefulWidget {
  final User? user;
  final String? name;
  final String role;

  const HomePage({super.key, this.user, this.name, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = _capitalizeFirstLetter(
      widget.name ??
          widget.user?.displayName ??
          widget.user?.email?.split('@').first ??
          'there',
    );
  }

  String _capitalizeFirstLetter(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'there';
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  Future<void> _openAccountSettings() async {
    final updatedName = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => AccountSettingsPage(name: _displayName),
      ),
    );
    if (!mounted || updatedName == null) return;
    setState(() => _displayName = updatedName);
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role.toLowerCase();
    if (role == 'parent') {
      return ParentHomePage(name: _displayName);
    }
    if (role == 'child') {
      return ChildHomePage(name: _displayName);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            tooltip: 'Account settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openAccountSettings,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountTypeSelectionPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Hi, $_displayName!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Logged in as: ${widget.user?.email ?? 'Unknown User'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Role: ${widget.role}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
