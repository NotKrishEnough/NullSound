import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../app/glass.dart';
import '../../home/presentation/home_page.dart';
import '../../search/presentation/search_page.dart';
import '../../library/presentation/library_page.dart';
import '../../player/presentation/mini_player.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override State<AppShell> createState() => _AppShellState();
}
class _AppShellState extends State<AppShell> {
  int index = 0;
  final pages = const [HomePage(), SearchPage(), LibraryPage()];
  @override Widget build(BuildContext context) => Scaffold(
    extendBody: true,
    body: GlassBackground(child: Stack(children: [
      IndexedStack(index: index, children: pages),
      const Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),
    ])),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xff2a2026).withValues(alpha: .78),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: .10)),
            ),
            child: NavigationBar(
              height: 76,
              selectedIndex: index,
              onDestinationSelected: (v) => setState(() => index = v),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Search'),
                NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music), label: 'Library'),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
