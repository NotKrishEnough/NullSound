import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'null_audio_handler.dart';

final audioHandlerProvider = Provider<NullAudioHandler>((ref) {
  throw UnimplementedError('Audio handler must be initialized before runApp.');
});
