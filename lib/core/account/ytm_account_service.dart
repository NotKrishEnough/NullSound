import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class YtmPlaylist {
  const YtmPlaylist({required this.id, required this.title});
  final String id;
  final String title;
}

class YtmAccountService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'nullsound_ytm_cookies';
  static const _apiKey = 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30';
  static const _version = '1.20260304.03.00';
  String? _cookies;
  String? lastError;
  String? _lastHttpError;
  bool get isSignedIn => _cookies != null && _cookies!.isNotEmpty;

  Future<void> restore() async => _cookies = await _storage.read(key: _key);

  Future<bool> saveAndVerify(String cookies) async {
    lastError = null;
    if (!cookies.contains('SAPISID') &&
        !cookies.contains('__Secure-3PAPISID') &&
        !cookies.contains('SID')) {
      lastError = 'The WebView did not expose a YouTube session cookie (SAPISID/SID).';
      return false;
    }
    _cookies = cookies;
    try {
      final response = await _browse('FEmusic_library_corpus_playlists');
      if (response == null) {
        lastError = _lastHttpError ?? 'YouTube Music did not accept this session.';
        _cookies = null;
        return false;
      }
      await _storage.write(key: _key, value: cookies);
      return true;
    } catch (e) {
      lastError = 'Session check failed: $e';
      _cookies = null;
      return false;
    }
  }

  Future<void> signOut() async {
    _cookies = null;
    await _storage.delete(key: _key);
  }

  Map<String, String> _headers() {
    final result = <String, String>{
      'Cookie': _cookies ?? '',
      'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
      'x-youtube-client-name': '67',
      'x-youtube-client-version': _version,
      'x-origin': 'https://music.youtube.com',
      'Content-Type': 'application/json',
    };
    final map = <String,String>{};
    for (final part in (_cookies ?? '').split(';')) {
      final i = part.indexOf('=');
      if (i > 0) map[part.substring(0,i).trim()] = part.substring(i+1).trim();
    }
    final sid = map['SAPISID'] ?? map['__Secure-3PAPISID'];
    if (sid != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final digest = sha1.convert(utf8.encode('$timestamp $sid https://music.youtube.com'));
      result['Authorization'] = 'SAPISIDHASH ${timestamp}_$digest';
    }
    return result;
  }

  Future<Map<String,dynamic>?> _browse(String browseId) async {
    if (!isSignedIn) return null;
    _lastHttpError = null;
    final response = await http.post(
      Uri.parse('https://music.youtube.com/youtubei/v1/browse?key=$_apiKey&prettyPrint=false'),
      headers: _headers(),
      body: jsonEncode({'context': {'client': {
        'clientName':'WEB_REMIX','clientVersion':_version,'hl':'en','gl':'US'
      }}, 'browseId':browseId}),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      _lastHttpError = 'YouTube Music returned HTTP ${response.statusCode}.';
      return null;
    }
    final decoded = jsonDecode(response.body);
    return decoded is Map<String,dynamic> ? decoded : null;
  }


  Future<List<Map<String,String>>> fetchPlaylistTracks(String playlistId) async {
    final data = await _browse(playlistId.startsWith('VL') ? playlistId : 'VL$playlistId');
    if (data == null) return [];
    final tracks = <Map<String,String>>[];
    final seen = <String>{};
    void walk(dynamic node) {
      if (node is Map) {
        final renderer = node['musicResponsiveListItemRenderer'];
        if (renderer is Map) {
          final videoId = renderer['playlistItemData']?['videoId'] ??
            renderer['navigationEndpoint']?['watchEndpoint']?['videoId'];
          final columns = renderer['flexColumns'] as List?;
          String title = 'Unknown title';
          String artist = 'Unknown artist';
          if (columns != null && columns.isNotEmpty) {
            final runs = columns[0]['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List?;
            if (runs != null && runs.isNotEmpty) title = runs.first['text']?.toString() ?? title;
          }
          if (columns != null && columns.length > 1) {
            final runs = columns[1]['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List?;
            if (runs != null && runs.isNotEmpty) artist = runs.first['text']?.toString() ?? artist;
          }
          if (videoId is String && videoId.isNotEmpty && seen.add(videoId)) {
            tracks.add({'id':videoId,'title':title,'artist':artist});
          }
        }
        for (final value in node.values) { walk(value); }
      } else if (node is List) { for (final value in node) { walk(value); } }
    }
    walk(data);
    return tracks;
  }

  Future<List<YtmPlaylist>> fetchPlaylists() async {
    final results = <YtmPlaylist>[];
    final seen = <String>{};
    for (final browseId in ['FEmusic_library_corpus_playlists','FEmusic_liked_playlists']) {
      final data = await _browse(browseId);
      if (data == null) continue;
      void walk(dynamic node) {
        if (node is Map) {
          final renderer = node['playlistRenderer'] ?? node['musicTwoRowItemRenderer'];
          if (renderer is Map) {
            final id = renderer['playlistId'] ??
              renderer['navigationEndpoint']?['browseEndpoint']?['browseId'];
            final title = renderer['title']?['runs']?[0]?['text'] ??
              renderer['title']?['simpleText'];
            if (id is String && title is String && id.isNotEmpty && seen.add(id)) {
              results.add(YtmPlaylist(id:id,title:title));
            }
          }
          for (final value in node.values) { walk(value); }
        } else if (node is List) { for (final value in node) { walk(value); } }
      }
      walk(data);
    }
    return results;
  }
}
