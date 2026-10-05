import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../core/audio/null_audio_handler.dart';

class FullPlayerPage extends StatefulWidget {
  const FullPlayerPage({super.key, required this.handler});

  final NullAudioHandler handler;

  @override
  State<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends State<FullPlayerPage> {
  Color _background = const Color(0xff171717);
  String? _paletteUri;
  bool _seeking = false;
  double _seekValue = 0;
  double _dragOffset = 0;
  double _horizontalDrag = 0;
  bool _showLyrics = false;
  bool _shuffle = false;
  int _repeatMode = 0;
  Duration? _sleepTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _updatePalette(String? uri) async {
    if (uri == null || uri.isEmpty || uri == _paletteUri) return;
    _paletteUri = uri;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(uri),
        maximumColorCount: 24,
      );
      final color = palette.dominantColor?.color ??
          palette.darkVibrantColor?.color ??
          palette.vibrantColor?.color;
      if (!mounted || color == null || uri != _paletteUri) return;
      setState(() {
        _background = Color.lerp(color, Colors.black, .32) ?? color;
      });
    } catch (_) {}
  }

  String _time(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '${d.inMinutes}:$s';
  }

  void _close() => Navigator.of(context).pop();

  Future<void> _showSleepTimer() async {
    final selected = await showModalBottomSheet<Duration?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _GlassSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sleep Timer', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
            ...[null, 15, 30, 45, 60, 120].map((minutes) {
              final duration = minutes == null ? null : Duration(minutes: minutes);
              return ListTile(
                leading: Icon(minutes == null ? Icons.timer_off_rounded : Icons.timer_rounded),
                title: Text(minutes == null ? 'Off' : '$minutes minutes'),
                trailing: _sleepTimer == duration ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.pop(context, duration),
              );
            }),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _sleepTimer = selected);
    if (selected != null) {
      Future.delayed(selected, () {
        if (mounted && _sleepTimer == selected) {
          widget.handler.pause();
          setState(() => _sleepTimer = null);
        }
      });
    }
  }

  Future<void> _showOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _GlassSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Playback', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
            SwitchListTile(
              value: _shuffle,
              onChanged: (v) => setState(() => _shuffle = v),
              title: const Text('Shuffle'),
              secondary: const Icon(Icons.shuffle_rounded),
            ),
            ListTile(
              leading: const Icon(Icons.repeat_rounded),
              title: const Text('Repeat'),
              trailing: Text(_repeatMode == 0 ? 'Off' : _repeatMode == 1 ? 'All' : 'One'),
              onTap: () => setState(() => _repeatMode = (_repeatMode + 1) % 3),
            ),
            ListTile(
              leading: const Icon(Icons.timer_rounded),
              title: const Text('Sleep timer'),
              onTap: _showSleepTimer,
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _showQueue() async {
    final items = widget.handler.queue.value;
    if (items.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 560),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: .94),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(22, 20, 22, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Up Next',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.artUri == null
                                ? const SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Icon(Icons.music_note_rounded),
                                  )
                                : Image.network(
                                    item.artUri.toString(),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            item.artist ?? 'Unknown artist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<MediaItem?>(
        stream: widget.handler.mediaItem,
        builder: (context, snapshot) {
          final item = snapshot.data;
          _updatePalette(item?.artUri?.toString());

          return AnimatedContainer(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            color: _background,
            child: Stack(
              children: [
                if (item?.artUri != null)
                  Positioned.fill(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                      child: Image.network(
                        item!.artUri.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .28),
                          Colors.black.withValues(alpha: .48),
                          Colors.black.withValues(alpha: .88),
                        ],
                        stops: const [0, .48, 1],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      _horizontalDrag += details.primaryDelta ?? 0;
                    },
                    onHorizontalDragEnd: (_) {
                      final delta = _horizontalDrag;
                      _horizontalDrag = 0;
                      if (delta.abs() < 70) return;
                      if (delta < 0) {
                        widget.handler.skipToNext();
                      } else {
                        widget.handler.skipToPrevious();
                      }
                    },
                    onVerticalDragUpdate: (details) {
                      if ((details.primaryDelta ?? 0) > 0) {
                        setState(() {
                          _dragOffset = (_dragOffset + details.primaryDelta!).clamp(0, 260);
                        });
                      }
                    },
                    onVerticalDragEnd: (_) {
                      if (_dragOffset > 120) {
                        _close();
                      } else {
                        setState(() => _dragOffset = 0);
                      }
                    },
                    child: Transform.translate(
                      offset: Offset(0, _dragOffset),
                      child: Opacity(
                        opacity: (1 - (_dragOffset / 420)).clamp(.45, 1),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxHeight < 720;
                            final artworkSize = (constraints.maxWidth - 42).clamp(220.0, compact ? 360.0 : 430.0).toDouble();

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      _PlayerIconButton(
                                        icon: Icons.keyboard_arrow_down_rounded,
                                        onTap: _close,
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'NOW PLAYING',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2.1,
                                        ),
                                      ),
                                      const Spacer(),
                                      _PlayerIconButton(
                                        icon: Icons.more_horiz_rounded,
                                        onTap: _showOptions,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: compact ? 16 : 30),
                                  SizedBox(
                                    width: artworkSize,
                                    height: artworkSize,
                                    child: Hero(
                                      tag: 'nullsound-current-art',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: item?.artUri == null
                                            ? Container(
                                                color: Colors.white12,
                                                child: const Icon(
                                                  Icons.music_note_rounded,
                                                  size: 100,
                                                ),
                                              )
                                            : Image.network(
                                                item!.artUri.toString(),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  color: Colors.white12,
                                                  child: const Icon(
                                                    Icons.music_note_rounded,
                                                    size: 100,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 18 : 25),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item?.title ?? 'Nothing playing',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 23,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -.3,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              item?.artist ?? 'Unknown artist',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white.withValues(alpha: .72),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _PlayerIconButton(
                                        icon: Icons.favorite_border_rounded,
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: compact ? 12 : 20),
                                  StreamBuilder<Duration?>(
                                    stream: widget.handler.player.durationStream,
                                    builder: (context, durationSnapshot) {
                                      final duration = durationSnapshot.data ?? Duration.zero;
                                      final max = duration.inMilliseconds
                                          .toDouble()
                                          .clamp(1, double.infinity)
                                          .toDouble();

                                      return StreamBuilder<Duration>(
                                        stream: widget.handler.player.positionStream,
                                        builder: (context, positionSnapshot) {
                                          final position = positionSnapshot.data ?? Duration.zero;
                                          final value = _seeking
                                              ? _seekValue
                                              : position.inMilliseconds
                                                  .toDouble()
                                                  .clamp(0, max)
                                                  .toDouble();

                                          return Column(
                                            children: [
                                              SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  trackHeight: 4,
                                                  thumbShape: const RoundSliderThumbShape(
                                                    enabledThumbRadius: 6,
                                                  ),
                                                  overlayShape: const RoundSliderOverlayShape(
                                                    overlayRadius: 14,
                                                  ),
                                                ),
                                                child: Slider(
                                                  value: value.clamp(0, max).toDouble(),
                                                  min: 0,
                                                  max: max,
                                                  onChangeStart: (value) {
                                                    setState(() {
                                                      _seeking = true;
                                                      _seekValue = value;
                                                    });
                                                  },
                                                  onChanged: (value) {
                                                    setState(() => _seekValue = value);
                                                  },
                                                  onChangeEnd: (value) {
                                                    widget.handler.seek(
                                                      Duration(milliseconds: value.round()),
                                                    );
                                                    setState(() => _seeking = false);
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      _time(position),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white.withValues(alpha: .72),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      _time(duration),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white.withValues(alpha: .72),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(height: compact ? 5 : 10),
                                  StreamBuilder<PlaybackState>(
                                    stream: widget.handler.playbackState,
                                    builder: (context, stateSnapshot) {
                                      final playing = stateSnapshot.data?.playing ?? false;
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _PlayerIconButton(
                                            icon: Icons.shuffle_rounded,
                                            onTap: () => setState(() => _shuffle = !_shuffle),
                                          ),
                                          _PlayerIconButton(
                                            icon: Icons.skip_previous_rounded,
                                            size: 34,
                                            onTap: widget.handler.skipToPrevious,
                                          ),
                                          GestureDetector(
                                            onTap: playing
                                                ? widget.handler.pause
                                                : widget.handler.play,
                                            child: Container(
                                              width: 72,
                                              height: 72,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                playing
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                                color: Colors.black,
                                                size: 39,
                                              ),
                                            ),
                                          ),
                                          _PlayerIconButton(
                                            icon: Icons.skip_next_rounded,
                                            size: 34,
                                            onTap: widget.handler.skipToNext,
                                          ),
                                          _PlayerIconButton(
                                            icon: Icons.repeat_rounded,
                                            onTap: () => setState(() => _repeatMode = (_repeatMode + 1) % 3),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _BottomAction(
                                        icon: Icons.airplay_rounded,
                                        label: 'AirPlay',
                                        onTap: () {},
                                      ),
                                      _BottomAction(
                                        icon: Icons.queue_music_rounded,
                                        label: 'Up Next',
                                        onTap: _showQueue,
                                      ),
                                      _BottomAction(
                                        icon: Icons.lyrics_outlined,
                                        label: 'Lyrics',
                                        onTap: () => setState(() => _showLyrics = !_showLyrics),
                                      ),
                                      _BottomAction(
                                        icon: Icons.share_outlined,
                                        label: 'Share',
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.paddingOf(context).bottom),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GlassSheet extends StatelessWidget {
  const _GlassSheet({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: .96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(child: child),
        ),
      ),
    );
  }
}

class _PlayerIconButton extends StatelessWidget {
  const _PlayerIconButton({
    required this.icon,
    required this.onTap,
    this.size = 28,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      icon: Icon(icon, size: size, color: Colors.white),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: Colors.white.withValues(alpha: .9)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: .72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
