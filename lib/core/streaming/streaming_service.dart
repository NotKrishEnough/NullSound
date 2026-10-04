import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Independent adapter around the public YouTube stream resolver.
/// Availability and formats can change; callers should handle resolver failures.
class StreamingService {
 final YoutubeExplode _yt = YoutubeExplode();
 Future<List<Video>> search(String query) async => (await _yt.search.search(query)).toList();
 Future<AudioOnlyStreamInfo> resolve(String videoId) async {
  final manifest = await _yt.videos.streamsClient.getManifest(videoId);
  final streams = manifest.audioOnly;
  if (streams.isEmpty) throw StateError('No audio-only stream is available.');
  return streams.withHighestBitrate();
 }
 void dispose()=>_yt.close();
}
