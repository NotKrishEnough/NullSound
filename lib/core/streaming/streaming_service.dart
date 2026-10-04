import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Resolves public YouTube audio-only formats for the player.
class StreamingService {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<List<Video>> search(String query) async =>
      (await _yt.search.search(query)).toList();

  Future<AudioOnlyStreamInfo> resolve(String videoId) async {
    final manifest = await _yt.videos.streamsClient.getManifest(
      videoId,
      ytClients: [YoutubeApiClient.ios, YoutubeApiClient.androidVr],
    );
    final streams = manifest.audioOnly;
    if (streams.isEmpty) {
      throw StateError('YouTube returned no audio-only formats for this track.');
    }

    // Prefer AAC in an MP4 container: it is broadly supported by Android
    // Media3/ExoPlayer. Fall back to the best audio-only format if unavailable.
    final compatible = streams.where((stream) {
      final container = stream.container.toString().toLowerCase();
      final codec = stream.audioCodec.toLowerCase();
      return container.contains('mp4') &&
          (codec.contains('mp4a') || codec.contains('aac'));
    }).toList();

    return (compatible.isNotEmpty ? compatible : streams).withHighestBitrate();
  }

  void dispose() => _yt.close();
}
