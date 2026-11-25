import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key, required this.name, this.demoMode = false});
  final String name;
  final bool demoMode;

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  int _tab = 0;
  String _child = 'Alex';
  bool _approved = false;
  final List<String> _assigned = [];
  static const _teal = Color(0xFF16796E);
  final _pages = ['Home', 'Tasks', 'Routines', 'Rewards', 'Profile'];

  Future<void> _assignTask() async {
    final controller = TextEditingController();
    final form = GlobalKey<FormState>();
    final recipient = _child;
    final title = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: Text('Assign a task to $recipient'),
      content: Form(key: form, child: TextFormField(
        controller: controller,
        autofocus: true,
        maxLength: 60,
        decoration: const InputDecoration(labelText: 'Task title', hintText: 'e.g. Read for 15 minutes'),
        validator: (value) => value == null || value.trim().isEmpty ? 'Enter a task title' : null,
      )),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(context, controller.text.trim()); }, child: const Text('Assign task')),
      ],
    ));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (!mounted || title == null) return;
    setState(() => _assigned.add('$recipient: $title'));
  }

  Future<void> _logout() async {
    try {
      if (!widget.demoMode) {
        await FirebaseAuth.instance.signOut();
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not log out: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF2F7F6),
    appBar: AppBar(backgroundColor: const Color(0xFFF2F7F6), title: const Text('RemindMe', style: TextStyle(fontWeight: FontWeight.bold))),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: _tab == 0 ? [
      Text('Hi, ${widget.name}! 👋', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const Text('A little support makes a big difference.'),
      const SizedBox(height: 22),
      const Text('Your family', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Wrap(spacing: 10, children: ['Alex', 'Sam'].map((name) => ChoiceChip(label: Text(name), avatar: const Icon(Icons.face), selected: _child == name, onSelected: (_) => setState(() => _child = name))).toList()),
      const SizedBox(height: 16),
      _card(color: _teal, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$_child’s day', style: const TextStyle(color: Colors.white, fontSize: 20)),
        const SizedBox(height: 12),
        Text(_child == 'Alex' ? '6/10 tasks completed' : '3/5 tasks completed', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        const SizedBox(height: 14),
        const LinearProgressIndicator(value: .6, minHeight: 10, color: Color(0xFFB9F1DB), backgroundColor: Color(0xFF0C5C52)),
        const SizedBox(height: 12),
        Text(_child == 'Alex' ? '60% finished • 70 points' : '60% finished • 40 points', style: const TextStyle(color: Colors.white)),
      ])),
      const SizedBox(height: 18),
      FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: _teal, padding: const EdgeInsets.all(16)), onPressed: widget.demoMode ? _assignTask : null, icon: const Icon(Icons.add), label: const Text('Create task')),
      const SizedBox(height: 20),
      const Text('Coming up', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      _card(child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.menu_book_outlined, color: _teal), title: Text(_child == 'Alex' ? 'Finish homework' : 'Reading time'), subtitle: Text('$_child • Due in 20 min'))),
      if (_assigned.isNotEmpty) ...[
        const SizedBox(height: 18),
        const Text('Assigned in this demo', style: TextStyle(fontWeight: FontWeight.bold)),
        ..._assigned.map((title) => ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(title))),
      ],
      const SizedBox(height: 20),
      const Text('Needs your attention', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      _card(color: const Color(0xFFFFF1D8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.card_giftcard_outlined, color: Color(0xFF906100)),
        const SizedBox(height: 10),
        const Text('Sam requested screen time', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const Text('Previously earned reward • Ready for review'),
        const SizedBox(height: 12),
        FilledButton(onPressed: !widget.demoMode || _approved ? null : () => setState(() => _approved = true), child: Text(_approved ? 'Approved in demo' : 'Approve reward')),
      ])),
      const SizedBox(height: 20),
      const Text('Recent activity', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.task_alt, color: _teal), title: Text('Alex packed their school bag'), subtitle: Text('Sample activity • +10 points')),
    ] : _tab == 4 ? [
      const Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      _card(child: Column(children: [
        const CircleAvatar(radius: 32, child: Icon(Icons.person_outline, size: 36)),
        const SizedBox(height: 12),
        Text(widget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ),
      ])),
    ] : [
      Text(_pages[_tab], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      _card(child: Column(children: [const Icon(Icons.construction, size: 40), const SizedBox(height: 16), Text('Parent ${_pages[_tab]} page coming soon'), const Text('Navigation placeholder for the team’s future page.', textAlign: TextAlign.center), TextButton(onPressed: () => setState(() => _tab = 0), child: const Text('Back to Home'))])),
    ])),
    bottomNavigationBar: NavigationBar(selectedIndex: _tab, onDestinationSelected: (index) => setState(() => _tab = index), indicatorColor: const Color(0xFFCFEBE4), destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
      NavigationDestination(icon: Icon(Icons.repeat), label: 'Routines'),
      NavigationDestination(icon: Icon(Icons.card_giftcard_outlined), label: 'Rewards'),
      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
    ]),
  );

  Widget _card({required Widget child, Color color = Colors.white}) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)), child: child);
}
