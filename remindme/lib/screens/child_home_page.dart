import 'package:flutter/material.dart';

/// Child homepage prototype. Demo interactions are local, not saved to Firebase.
class ChildHomePage extends StatefulWidget {
  const ChildHomePage({super.key, required this.name, this.demoMode = false});
  final String name;
  final bool demoMode;

  @override
  State<ChildHomePage> createState() => _ChildHomePageState();
}

class _ChildHomePageState extends State<ChildHomePage> {
  static const _ink = Color(0xFF243451);
  static const _purple = Color(0xFF6554CF);
  int _tab = 0;
  int _completed = 6;
  int _points = 70;
  bool _started = false;
  bool _finishedHomework = false;
  final _pages = ['Home', 'Tasks', 'Routines', 'Rewards', 'Profile'];

  void _reset() => setState(() {
    _tab = 0;
    _completed = 6;
    _points = 70;
    _started = false;
    _finishedHomework = false;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F5FC),
    appBar: AppBar(
      backgroundColor: const Color(0xFFF6F5FC),
      title: const Text('RemindMe', style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
      titleSpacing: 12,
      actions: [
        if (widget.demoMode) IconButton(tooltip: 'Reset demo', onPressed: _reset, icon: const Icon(Icons.restart_alt)),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Chip(avatar: const Icon(Icons.stars_rounded, color: Color(0xFFAC7600)), label: Text('$_points points', style: const TextStyle(fontWeight: FontWeight.bold))),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _tab == 0 ? _home() : _placeholder(),
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (index) => setState(() => _tab = index),
      indicatorColor: const Color(0xFFE4DEFF),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'Tasks'),
        NavigationDestination(icon: Icon(Icons.repeat_rounded), label: 'Routines'),
        NavigationDestination(icon: Icon(Icons.card_giftcard_rounded), label: 'Rewards'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    ),
  );

  Widget _home() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      if (widget.demoMode) ...[
        const Text('CHILD HOMEPAGE DEMO • Sample data', style: TextStyle(color: _purple, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 16),
      ],
      Text('Hi, ${widget.name}! 👋', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _ink)),
      const SizedBox(height: 6),
      const Text('Small steps. Big wins. You’ve got this!', style: TextStyle(color: Color(0xFF647089), fontSize: 16)),
      const SizedBox(height: 24),
      _card(
        color: _purple,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.rocket_launch_outlined, color: Colors.white), SizedBox(width: 10), Expanded(child: Text('Your progress today', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)))]),
          const SizedBox(height: 18),
          Text('${(_completed / 10 * 100).round()}% finished', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: _completed / 10, minHeight: 10, borderRadius: BorderRadius.circular(10), color: const Color(0xFFD9D1FF), backgroundColor: const Color(0xFF4F40AA), semanticsLabel: 'Daily task progress'),
          const SizedBox(height: 12),
          Text('$_completed/10 tasks completed', style: const TextStyle(color: Colors.white)),
        ]),
      ),
      const SizedBox(height: 22),
      const Text('Up next', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: _ink)),
      const SizedBox(height: 12),
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(backgroundColor: Color(0xFFECE8FF), child: Icon(Icons.menu_book_rounded, color: _purple)),
          const SizedBox(width: 12),
          Expanded(child: Text(_finishedHomework ? 'Homework complete!' : 'Finish your homework', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ink))),
        ]),
        const SizedBox(height: 14),
        Text(_finishedHomework ? 'Great effort! You earned 10 points.' : 'Due in 20 min • +10 points', style: const TextStyle(color: Color(0xFF647089))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: _purple, padding: const EdgeInsets.all(16)),
          onPressed: !widget.demoMode || _finishedHomework ? null : () => setState(() {
            if (_started) {
              _finishedHomework = true;
              _completed += 1;
              _points += 10;
            } else {
              _started = true;
            }
          }),
          icon: Icon(_finishedHomework ? Icons.check_circle_outline : _started ? Icons.task_alt : Icons.play_arrow_rounded),
          label: Text(_finishedHomework ? 'Completed' : _started ? 'Mark complete' : 'Start task'),
        )),
        if (_started && !_finishedHomework) const Padding(padding: EdgeInsets.only(top: 10), child: Text('Task started. Mark it complete when you finish.')),
        if (!widget.demoMode) const Text('Task actions will be enabled when live task data is connected.'),
      ])),
      const SizedBox(height: 22),
      const Text('Your next reward', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: _ink)),
      const SizedBox(height: 12),
      _card(color: const Color(0xFFFFF1D8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.sports_esports_outlined, color: Color(0xFF906100), size: 30), SizedBox(width: 12), Expanded(child: Text('Screen time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ink)))]),
        const SizedBox(height: 14),
        Text('$_points/100 points', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _ink)),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: (_points / 100).clamp(0.0, 1.0), color: const Color(0xFFE0A128), backgroundColor: const Color(0xFFF0DDB7), minHeight: 8, borderRadius: BorderRadius.circular(8), semanticsLabel: 'Screen time reward progress'),
        const SizedBox(height: 12),
        Text('Only ${100 - _points} more points to reach your goal!', style: const TextStyle(color: Color(0xFF795D28))),
        TextButton(onPressed: () => setState(() => _tab = 3), child: const Text('View rewards →')),
      ])),
      const SizedBox(height: 18),
      const Text('Prototype: task counts, points, and due time are sample data. Changes are not saved. Other tabs are navigation placeholders.', style: TextStyle(fontSize: 12, color: Color(0xFF647089))),
    ],
  );

  Widget _placeholder() => ListView(padding: const EdgeInsets.all(24), children: [
    Text(_pages[_tab], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: _ink)),
    const SizedBox(height: 18),
    _card(child: Column(children: [
      const Icon(Icons.construction_rounded, size: 48, color: _purple),
      const SizedBox(height: 14),
      Text('${_pages[_tab]} page coming soon', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      const Text('This demo covers the child homepage. This tab shows where the team’s future page will connect.', textAlign: TextAlign.center),
      const SizedBox(height: 16),
      FilledButton(onPressed: () => setState(() => _tab = 0), child: const Text('Back to Home')),
    ])),
  ]);

  Widget _card({required Widget child, Color color = Colors.white}) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
    child: child,
  );
}
