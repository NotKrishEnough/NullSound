import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_provider.dart';
import '../../../core/library/library_store.dart';
import '../../../core/streaming/streaming_provider.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});
  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  int tab = 0;
  Future<void> createPlaylist() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: const Text('New playlist'),
      content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Playlist name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Create')),
      ],
    ));
    controller.dispose();
    if (name == null || name.isEmpty) return;
    await LibraryStore.createPlaylist(name);
    if (mounted) setState(() {});
  }

  Future<void> playTrack(Map<String, dynamic> data) async {
    final item = LibraryStore.decode(data);
    await ref.read(audioHandlerProvider).playQueue(
      items: [item], startIndex: 0,
      resolve: (track) async => (await ref.read(streamingServiceProvider).resolve(track.id)).url.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracks = LibraryStore.tracks;
    final playlists = LibraryStore.playlists;
    return Scaffold(
      appBar: AppBar(title: const Text('Your library'), actions: [
        IconButton(tooltip: 'Create playlist', onPressed: createPlaylist, icon: const Icon(Icons.add)),
      ]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Songs'), icon: Icon(Icons.music_note)),
            ButtonSegment(value: 1, label: Text('Playlists'), icon: Icon(Icons.queue_music)),
          ],
          selected: {tab}, onSelectionChanged: (value) => setState(() => tab = value.first),
        )),
        const SizedBox(height: 8),
        Expanded(child: tab == 0
          ? tracks.isEmpty
            ? const Center(child: Text('Save songs from Search to find them here.'))
            : ListView(children: tracks.map((data) => ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(data['title'] as String, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text((data['artist'] as String?) ?? ''),
                onTap: () => playTrack(data),
              )).toList())
          : playlists.isEmpty
            ? const Center(child: Text('Create a playlist to get started.'))
            : ListView(children: playlists.map((playlist) {
                final name = playlist['name'] as String;
                final songs = List<Map<String, dynamic>>.from((playlist['tracks'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
                return ExpansionTile(
                  leading: const Icon(Icons.queue_music),
                  title: Text(name),
                  subtitle: Text('${songs.length} songs'),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
                    await LibraryStore.removePlaylist(name); setState(() {});
                  }),
                  children: songs.isEmpty
                    ? [const ListTile(title: Text('No songs yet'))]
                    : songs.map((song) => ListTile(
                        title: Text(song['title'] as String, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text((song['artist'] as String?) ?? ''),
                        onTap: () => playTrack(song),
                      )).toList(),
                );
              }).toList())),
      ]),
    );
  }
}
