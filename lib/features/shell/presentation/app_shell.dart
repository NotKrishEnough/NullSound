import 'package:flutter/material.dart';
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
    body: Stack(children: [
      IndexedStack(index: index, children: pages),
      const Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),
    ]),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      child: ClipRRect(borderRadius: BorderRadius.circular(32), child: NavigationBar(
        selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music), label: 'Library'),
        ],
      )),
    ),
  );
}
