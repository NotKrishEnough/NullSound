import 'dart:ui';
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
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xff382b33).withValues(alpha:.86),borderRadius:BorderRadius.circular(23),border:Border.all(color:Colors.white.withValues(alpha:.12))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal:12,vertical:4),
                  leading: item.artUri == null ? const Icon(Icons.music_note) : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(item.artUri.toString(), width: 48, height: 48, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.music_note)),
                  ),
                  title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(item.artist ?? 'Unknown artist', maxLines: 1),
                  trailing: StreamBuilder<PlaybackState>(
                    stream: handler.playbackState,
                    builder: (context, state) => IconButton(
                      icon: Icon(state.data?.playing == true ? Icons.pause_rounded : Icons.play_arrow_rounded,size:30),
                      onPressed: () => state.data?.playing == true ? handler.pause() : handler.play(),
                    ),
                  ),
                  onTap: () => showModalBottomSheet<void>(
                    context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Colors.transparent,
                    builder: (_) => _ExpandedPlayer(handler: handler),
                  ),
                ),
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
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(top:Radius.circular(32)),
    child: BackdropFilter(filter:ImageFilter.blur(sigmaX:25,sigmaY:25),child: Container(
      color:const Color(0xff211a20).withValues(alpha:.96),
      height: MediaQuery.sizeOf(context).height * .88,
      child: StreamBuilder<MediaItem?>(
        stream: handler.mediaItem,
        builder: (context, snapshot) {
          final item = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (item?.artUri != null) ClipRRect(
                borderRadius: BorderRadius.circular(28),
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
                  IconButton(onPressed: handler.skipToPrevious, icon: const Icon(Icons.skip_previous_rounded, size: 40)),
                  IconButton(onPressed: () => state.data?.playing == true ? handler.pause() : handler.play(),
                    icon: Icon(state.data?.playing == true ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, size: 68)),
                  IconButton(onPressed: handler.skipToNext, icon: const Icon(Icons.skip_next_rounded, size: 40)),
                ]),
              ),
            ]),
          );
        },
      ),
    )),
  );
}
