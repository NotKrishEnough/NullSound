import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class NullAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
 final AudioPlayer player = AudioPlayer();
 NullAudioHandler() {
  player.playbackEventStream.listen((event) {
   playbackState.add(PlaybackState(
    controls: [MediaControl.skipToPrevious, player.playing ? MediaControl.pause : MediaControl.play, MediaControl.skipToNext],
    systemActions: const {MediaAction.seek},
    androidCompactActionIndices: const [0,1,2],
    processingState: const {ProcessingState.idle:AudioProcessingState.idle,ProcessingState.loading:AudioProcessingState.loading,ProcessingState.buffering:AudioProcessingState.buffering,ProcessingState.ready:AudioProcessingState.ready,ProcessingState.completed:AudioProcessingState.completed}[player.processingState]!,
    playing: player.playing, updatePosition: player.position, bufferedPosition: player.bufferedPosition, speed: player.speed,
   ));
  });
 }
 @override Future<void> play()=>player.play();
 @override Future<void> pause()=>player.pause();
 @override Future<void> seek(Duration position)=>player.seek(position);
 @override Future<void> stop() async { await player.stop(); await super.stop(); }
}
