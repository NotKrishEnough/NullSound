import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_provider.dart';
import '../../../core/streaming/streaming_provider.dart';
import '../../../core/library/library_store.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final controller = TextEditingController();
  bool loading = false;
  String? error;
  List<dynamic> results = [];

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { loading = true; error = null; });
    try {
      final found = await ref.read(streamingServiceProvider).search(query.trim());
      if (mounted) setState(() => results = found);
    } catch (_) {
      if (mounted) setState(() => error = 'Search failed. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  MediaItem itemAt(int index) {\n    final video = results[index];\n    return MediaItem(id: video.id.value, title: video.title, artist: video.author, artUri: Uri.tryParse(video.thumbnails.highResUrl));\n  }\n\n  Future<void> save(int index) async {\n    await LibraryStore.saveTrack(itemAt(index));\n    if (!mounted) return;\n    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to your library')));\n  }\n\n  Future<void> addToPlaylist(int index) async {\n    final lists = LibraryStore.playlists;\n    if (lists.isEmpty) {\n      if (!mounted) return;\n      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create a playlist in Library first')));\n      return;\n    }\n    final selected = await showModalBottomSheet<String>(context: context, builder: (context) => SafeArea(child: ListView(shrinkWrap: true, children: [\n      const ListTile(title: Text('Add to playlist')),\n      ...lists.map((p) => ListTile(title: Text(p['name'] as String), onTap: () => Navigator.pop(context, p['name'] as String))),\n    ])));\n    if (selected == null) return;\n    await LibraryStore.addToPlaylist(selected, itemAt(index));\n    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to $selected')));\n  }\n\n  Future<void> play(int selectedIndex) async {
    try {
      setState(() => error = null);
      final service = ref.read(streamingServiceProvider);
      final items = results.map<MediaItem>((video) => MediaItem(
        id: video.id.value,
        title: video.title,
        artist: video.author,
        artUri: Uri.tryParse(video.thumbnails.highResUrl),
      )).toList();
      await ref.read(audioHandlerProvider).playQueue(
        items: items,
        startIndex: selectedIndex,
        resolve: (item) async {
          final stream = await service.resolve(item.id);
          return stream.url.toString();
        },
      );
    } catch (_) {
      if (mounted) setState(() => error = 'Could not start this track. Try another result.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Search')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: search,
          decoration: InputDecoration(
            hintText: 'Songs, artists, albums…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () => search(controller.text)),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
          ),
        ),
        if (loading) const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
        if (error != null) Padding(padding: const EdgeInsets.all(12), child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        Expanded(child: ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final video = results[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(video.thumbnails.highResUrl, width: 56, height: 56, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(width: 56, height: 56, child: Icon(Icons.music_note))),
              ),
              title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(video.author, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: PopupMenuButton<String>(\n                onSelected: (value) { if (value == 'save') save(index); if (value == 'playlist') addToPlaylist(index); },\n                itemBuilder: (_) => const [\n                  PopupMenuItem(value: 'save', child: Text('Save to library')),\n                  PopupMenuItem(value: 'playlist', child: Text('Add to playlist')),\n                ],\n                icon: const Icon(Icons.more_vert),\n              ),
              onTap: () => play(index),
            );
          },
        )),
      ]),
    ),
  );
}
