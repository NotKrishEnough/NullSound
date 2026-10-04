import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/audio/audio_provider.dart';
import 'core/audio/null_audio_handler.dart';
import 'core/library/library_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local storage is required by the Library screen, so initialize it before
  // mounting the app. Audio service startup is best-effort: a service/plugin
  // failure must not leave Android displaying the native launch screen forever.
  await LibraryStore.init();

  NullAudioHandler handler;
  try {
    handler = await AudioService.init<NullAudioHandler>(
      builder: NullAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'app.nullsound.audio',
        androidNotificationChannelName: 'NullSound playback',
        androidNotificationOngoing: true,
      ),
    ).timeout(const Duration(seconds: 10));
  } catch (error, stackTrace) {
    debugPrint('NullSound audio service initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    // The player can still be used in-app even if the Android media service
    // could not be registered. Most importantly, continue to render the UI.
    handler = NullAudioHandler();
  }

  runApp(ProviderScope(
    overrides: [audioHandlerProvider.overrideWithValue(handler)],
    child: const NullSoundApp(),
  ));
}
