import 'package:flutter/material.dart';
class HomePage extends StatelessWidget {
 const HomePage({super.key});
 @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(22,24,22,150), children: [
  Text('NullSound', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
  const SizedBox(height: 8), Text('Find your next favourite.', style: Theme.of(context).textTheme.bodyLarge),
  const SizedBox(height: 28), Text('Made for your mood', style: Theme.of(context).textTheme.titleLarge),
  const SizedBox(height: 14), Container(height: 190, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xff51417a),Color(0xffc06b86)])), child: const Center(child: Icon(Icons.graphic_eq, size: 64, color: Colors.white))),
  const SizedBox(height: 28), Text('Start listening', style: Theme.of(context).textTheme.titleLarge),
  const SizedBox(height: 8), const Text('Search for songs, albums, artists and playlists to build your library.'),
 ])));
}
