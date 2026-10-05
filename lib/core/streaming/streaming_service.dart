import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Resolves public YouTube audio-only formats for the player.
class StreamingService {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<List<Video>> search(String query) async =>
      (await _yt.search.search(query)).toList();

  Future<AudioOnlyStreamInfo> resolve(String videoId) async {
    Object? lastError;

    // Keep clients isolated: one blocked/invalid client should not poison the
    // manifest returned by another client. Android VR is currently the most
    // useful client for Android playback.
    for (final client in <YoutubeApiClient>[
      YoutubeApiClient.androidVr,
      YoutubeApiClient.safari,
      YoutubeApiClient.ios,
    ]) {
      try {
        final manifest = await _yt.videos.streamsClient.getManifest(
          videoId,
          ytClients: [client],
        );
        final streams = manifest.audioOnly;
        if (streams.isEmpty) continue;

        final compatible = streams.where((stream) {
          final container = stream.container.toString().toLowerCase();
          final codec = stream.audioCodec.toLowerCase();
          return container.contains('mp4') &&
              (codec.contains('mp4a') || codec.contains('aac'));
        }).toList();

        return (compatible.isNotEmpty ? compatible : streams).withHighestBitrate();
      } catch (e) {
        lastError = e;
      }
    }

    throw StateError(
      'YouTube did not provide a playable audio stream. '
      'The video may require YouTube sign-in or be temporarily restricted.'
      '${lastError == null ? '' : ' Last error: $lastError'}',
    );
  }

  void dispose() => _yt.close();
}