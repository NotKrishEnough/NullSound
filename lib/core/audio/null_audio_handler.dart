import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

typedef StreamUrlResolver = Future<String> Function(MediaItem item);

class NullAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer player = AudioPlayer();
  List<MediaItem> _items = [];
  int _index = 0;
  StreamUrlResolver? _resolver;
  bool _changingTrack = false;

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
    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed && !_changingTrack) skipToNext();
    });
  }

  Future<void> playQueue({
    required List<MediaItem> items,
    required int startIndex,
    required StreamUrlResolver resolve,
  }) async {
    if (items.isEmpty || startIndex < 0 || startIndex >= items.length) return;
    _items = List.unmodifiable(items);
    _index = startIndex;
    _resolver = resolve;
    queue.add(_items);
    await _loadCurrent(autoplay: true);
  }

  Future<void> _loadCurrent({required bool autoplay}) async {
    if (_items.isEmpty || _resolver == null) return;
    _changingTrack = true;
    try {
      final item = _items[_index];
      mediaItem.add(item);
      final url = await _resolver!(item);
      await player.setAudioSource(AudioSource.uri(Uri.parse(url), tag: item));
      if (autoplay) await player.play();
    } finally {
      _changingTrack = false;
    }
  }

  @override
  Future<void> skipToNext() async {
    if (_index + 1 >= _items.length) return;
    _index++;
    await _loadCurrent(autoplay: true);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_items.isEmpty) return;
    if (player.position > const Duration(seconds: 3)) {
      await player.seek(Duration.zero);
      return;
    }
    if (_index == 0) return;
    _index--;
    await _loadCurrent(autoplay: true);
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
