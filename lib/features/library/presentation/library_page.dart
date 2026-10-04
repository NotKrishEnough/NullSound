import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_provider.dart';
import '../../../core/library/library_store.dart';
import '../../../core/streaming/streaming_provider.dart';
import '../../../core/account/ytm_account_service.dart';
import '../../account/ytm_sign_in_page.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});
  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  int tab = 0;
  final account = YtmAccountService();
  List<YtmPlaylist> remotePlaylists = [];
  bool syncing = false;
  @override
  void initState() { super.initState(); account.restore().then((_) { if (mounted) setState(() {}); }); }
  Future<void> signIn() async {
    final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => YtmSignInPage(service: account)));
    if (ok == true && mounted) { setState(() {}); await syncPlaylists(); }
  }
  Future<void> syncPlaylists() async {
    if (!account.isSignedIn) return;
    setState(() => syncing = true);
    try { final result = await account.fetchPlaylists(); if (mounted) setState(() => remotePlaylists = result); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playlist sync failed. Try again later.'))); }
    finally { if (mounted) setState(() => syncing = false); }
  }
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
        if (account.isSignedIn) IconButton(tooltip: 'Sync YouTube Music playlists', onPressed: syncing ? null : syncPlaylists, icon: syncing ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.sync)),
        IconButton(tooltip: account.isSignedIn ? 'YouTube Music connected' : 'Sign in to YouTube Music', onPressed: signIn, icon: Icon(account.isSignedIn ? Icons.account_circle : Icons.login)),
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
        if (account.isSignedIn && tab == 1) Padding(padding: const EdgeInsets.fromLTRB(16,8,16,0), child: Row(children:[const Expanded(child:Text('YouTube Music playlists')), TextButton(onPressed:syncing ? null : syncPlaylists, child:const Text('Sync'))])),
        if (account.isSignedIn && tab == 1 && remotePlaylists.isNotEmpty) SizedBox(height:110, child:ListView.builder(scrollDirection:Axis.horizontal,itemCount:remotePlaylists.length,itemBuilder:(context,index){final item=remotePlaylists[index];return SizedBox(width:190,child:Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.cloud_queue),const Spacer(),Text(item.title,maxLines:2,overflow:TextOverflow.ellipsis),Text('YouTube Music',style:Theme.of(context).textTheme.labelSmall)]))));})),
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
