import 'package:flutter/material.dart';
import 'screens/child_home_page.dart';
import 'screens/parent_home_page.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'RemindMe — Mobile Homepage Demo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6554CF)), useMaterial3: true),
    // The Navigator and dialogs both live inside the same phone-sized viewport.
    builder: (context, child) => LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 500) return child!;
      return ColoredBox(color: const Color(0xFFE4E5EE), child: Center(child: Padding(
        padding: const EdgeInsets.all(12),
        child: FittedBox(fit: BoxFit.contain, child: Container(
          width: 390,
          height: 844,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(36)),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(borderRadius: BorderRadius.circular(28), child: MediaQuery(
            data: MediaQuery.of(context).copyWith(size: const Size(374, 828), padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero, viewInsets: EdgeInsets.zero),
            child: child!,
          )),
        )),
      )));
    }),
    home: const _DemoShell(),
  );
}

class _DemoShell extends StatefulWidget {
  const _DemoShell();
  @override
  State<_DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<_DemoShell> {
  String? _role;
  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return Scaffold(backgroundColor: const Color(0xFFF6F5FC), body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.notifications_active_outlined, size: 68, color: Color(0xFF6554CF)),
          const SizedBox(height: 20),
          const Text('RemindMe', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Little steps. Happier routines.', textAlign: TextAlign.center),
          const SizedBox(height: 40),
          const Text('Who’s using the app?', textAlign: TextAlign.center, style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          FilledButton.icon(style: FilledButton.styleFrom(padding: const EdgeInsets.all(20)), onPressed: () => setState(() => _role = 'Parent'), icon: const Icon(Icons.family_restroom), label: const Text('I’m a parent')),
          const SizedBox(height: 14),
          OutlinedButton.icon(style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(20)), onPressed: () => setState(() => _role = 'Child'), icon: const Icon(Icons.face), label: const Text('I’m a child')),
          const SizedBox(height: 24),
          const Text('Interactive UI demo • Sample data\nNo sign-in required', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
        ]),
      ))));
    }
    return Column(children: [
      Material(color: const Color(0xFFECE8FF), child: SafeArea(bottom: false, child: SizedBox(height: 44, child: Row(children: [
        TextButton.icon(onPressed: () => setState(() => _role = null), icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Switch role')),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text('$_role demo', textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis),
        )),
      ])))),
      Expanded(child: _role == 'Parent' ? const ParentHomePage(name: 'Falis', demoMode: true) : const ChildHomePage(name: 'Alex', demoMode: true)),
    ]);
  }
}

