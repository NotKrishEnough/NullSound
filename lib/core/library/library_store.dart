import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LibraryStore {
  static const _boxName = 'nullsound_library';
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_boxName);
  }
  static Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  static List<Map<String, dynamic>> get tracks =>
      (_box.get('tracks', defaultValue: <dynamic>[]) as List)
          .map((e) => Map<String, dynamic>.from(e as Map)).toList();

  static List<Map<String, dynamic>> get playlists =>
      (_box.get('playlists', defaultValue: <dynamic>[]) as List)
          .map((e) => Map<String, dynamic>.from(e as Map)).toList();

  static Future<void> saveTrack(MediaItem item) async {
    final all = tracks;
    if (all.any((e) => e['id'] == item.id)) return;
    all.add(_encode(item));
    await _box.put('tracks', all);
  }

  static Future<void> createPlaylist(String name) async {
    final all = playlists;
    all.add({'name': name, 'tracks': <dynamic>[]});
    await _box.put('playlists', all);
  }

  static Future<void> addToPlaylist(String name, MediaItem item) async {
    final all = playlists;
    final index = all.indexWhere((e) => e['name'] == name);
    if (index < 0) return;
    final items = List<Map<String, dynamic>>.from(
      (all[index]['tracks'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
    if (!items.any((e) => e['id'] == item.id)) items.add(_encode(item));
    all[index]['tracks'] = items;
    await _box.put('playlists', all);
  }

  static Future<void> removePlaylist(String name) async {
    final all = playlists..removeWhere((e) => e['name'] == name);
    await _box.put('playlists', all);
  }

  static MediaItem decode(Map<String, dynamic> data) => MediaItem(
    id: data['id'] as String,
    title: data['title'] as String,
    artist: data['artist'] as String?,
    artUri: data['artUri'] == null ? null : Uri.tryParse(data['artUri'] as String),
  );

  static Map<String, dynamic> _encode(MediaItem item) => {
    'id': item.id, 'title': item.title, 'artist': item.artist,
    'artUri': item.artUri?.toString(),
  };
}
