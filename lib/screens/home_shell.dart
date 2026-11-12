import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'alarms_tab.dart';
import 'sleep_tab.dart';
import 'you_tab.dart';

/// The app's spine: three tabs, no drawer, no hamburger.
///
/// Each tab answers exactly one question:
///   Alarms — "what will wake me, and when?"
///   Sleep  — "how did I sleep?"
///   You    — "how am I doing over time?"
///
/// Everything else is reached from a screen, never from the tab bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.isar});

  final Isar isar;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Alarms', 'Sleep', 'You'];

  @override
  Widget build(BuildContext context) {
    final tabs = [
      AlarmsTab(isar: widget.isar),
      SleepTab(isar: widget.isar),
      YouTab(isar: widget.isar),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: 'Alarms',
          ),
          NavigationDestination(
            icon: Icon(Icons.bedtime_outlined),
            selectedIcon: Icon(Icons.bedtime),
            label: 'Sleep',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'You',
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed('/alarm-new'),
              icon: const Icon(Icons.add),
              label: const Text('Alarm'),
            )
          : null,
    );
  }
}