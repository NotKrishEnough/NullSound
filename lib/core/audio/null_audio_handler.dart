import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class NullAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer player = AudioPlayer();

  NullAudioHandler() {
    player.playbackEventStream.listen((event) {
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[player.processingState]!,
        playing: player.playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
      ));
    });
  }

  Future<void> playStream({
    required String url,
    required String id,
    required String title,
    required String artist,
    String? artworkUrl,
  }) async {
    final item = MediaItem(
      id: id,
      title: title,
      artist: artist,
      artUri: artworkUrl == null ? null : Uri.tryParse(artworkUrl),
    );
    mediaItem.add(item);
    queue.add([item]);
    await player.setAudioSource(AudioSource.uri(Uri.parse(url), tag: item));
    await player.play();
  }

  @override
  Future<void> play() => player.play();
  @override
  Future<void> pause() => player.pause();
  @override
  Future<void> seek(Duration position) => player.seek(position);
  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }
}
