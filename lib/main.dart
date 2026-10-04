import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/audio/audio_provider.dart';
import 'core/audio/null_audio_handler.dart';
import 'core/library/library_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LibraryStore.init();
  final handler = await AudioService.init<NullAudioHandler>(
    builder: NullAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'app.nullsound.audio',
      androidNotificationChannelName: 'NullSound playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(ProviderScope(
    overrides: [audioHandlerProvider.overrideWithValue(handler)],
    child: const NullSoundApp(),
  ));
}
