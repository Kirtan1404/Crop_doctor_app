import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'placeholder_screen.dart';
import '../theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    PlaceholderScreen(
      title: 'Community',
      icon: Icons.forum_outlined,
      message: 'Connect with other farmers — coming soon.',
    ),
    PlaceholderScreen(
      title: 'Market',
      icon: Icons.storefront_outlined,
      message: 'Buy and sell crop inputs — coming soon.',
    ),
    PlaceholderScreen(
      title: 'You',
      icon: Icons.person_outline,
      message: 'Your profile and scan history — coming soon.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: AppTheme.lightGreen.withOpacity(0.3),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.eco_outlined), selectedIcon: Icon(Icons.eco), label: 'Your crops'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Community'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'You'),
        ],
      ),
    );
  }
}