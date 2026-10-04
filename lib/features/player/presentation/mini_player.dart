import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_provider.dart';
import '../../../core/audio/null_audio_handler.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(audioHandlerProvider);
    return StreamBuilder<MediaItem?>(
      stream: handler.mediaItem,
      builder: (context, snapshot) {
        final item = snapshot.data;
        if (item == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            child: ListTile(
              leading: item.artUri == null ? const Icon(Icons.music_note) : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(item.artUri.toString(), width: 44, height: 44, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.music_note)),
              ),
              title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(item.artist ?? 'Unknown artist', maxLines: 1),
              trailing: StreamBuilder<PlaybackState>(
                stream: handler.playbackState,
                builder: (context, state) => IconButton(
                  icon: Icon(state.data?.playing == true ? Icons.pause : Icons.play_arrow),
                  onPressed: () => state.data?.playing == true ? handler.pause() : handler.play(),
                ),
              ),
              onTap: () => showModalBottomSheet<void>(
                context: context, isScrollControlled: true, useSafeArea: true,
                builder: (_) => _ExpandedPlayer(handler: handler),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpandedPlayer extends StatelessWidget {
  const _ExpandedPlayer({required this.handler});
  final NullAudioHandler handler;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * .82,
    child: StreamBuilder<MediaItem?>(
      stream: handler.mediaItem,
      builder: (context, snapshot) {
        final item = snapshot.data;
        return Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (item?.artUri != null) ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(item!.artUri.toString(), height: 280, width: 280, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.music_note, size: 100)),
            ) else const Icon(Icons.music_note, size: 120),
            const SizedBox(height: 28),
            Text(item?.title ?? 'Nothing playing', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            Text(item?.artist ?? '', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 28),
            StreamBuilder<PlaybackState>(
              stream: handler.playbackState,
              builder: (context, state) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(onPressed: handler.skipToPrevious, icon: const Icon(Icons.skip_previous, size: 36)),
                IconButton(onPressed: () => state.data?.playing == true ? handler.pause() : handler.play(),
                  icon: Icon(state.data?.playing == true ? Icons.pause_circle : Icons.play_circle, size: 64)),
                IconButton(onPressed: handler.skipToNext, icon: const Icon(Icons.skip_next, size: 36)),
              ]),
            ),
          ]),
        );
      },
    ),
  );
}
