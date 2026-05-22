import 'package:flutter/material.dart';
import '../controller/smart_player_config.dart';
import '../controller/smart_player_controller.dart';
import '../controls/progress_bar.dart';
import '../theme/smart_player_theme.dart';

/// Audio player style
enum AudioPlayerStyle {
  /// Full screen podcast/music player (album art + controls)
  full,

  /// Compact bar (like Spotify mini player)
  compact,

  /// Just controls, no UI
  minimal,
}

/// SmartAudioPlayer — podcast / music / audiobook ke liye
///
/// ```dart
/// SmartAudioPlayer(
///   audioUrl: 'https://example.com/podcast.mp3',
///   title: 'Episode 42',
///   artist: 'My Podcast',
///   coverUrl: 'https://example.com/cover.jpg',
/// )
/// ```
class SmartAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String? title;
  final String? artist;
  final String? coverUrl;
  final AudioPlayerStyle style;
  final SmartPlayerTheme? theme;
  final bool enableBackgroundPlayback;
  final VoidCallback? onComplete;

  const SmartAudioPlayer({
    super.key,
    required this.audioUrl,
    this.title,
    this.artist,
    this.coverUrl,
    this.style = AudioPlayerStyle.full,
    this.theme,
    this.enableBackgroundPlayback = true,
    this.onComplete,
  });

  @override
  State<SmartAudioPlayer> createState() => _SmartAudioPlayerState();
}

class _SmartAudioPlayerState extends State<SmartAudioPlayer>
    with SingleTickerProviderStateMixin {
  late SmartPlayerController _controller;
  late AnimationController _albumArtAnimation;

  SmartPlayerTheme get _theme =>
      widget.theme ?? SmartPlayerTheme(primaryColor: Colors.purple);

  @override
  void initState() {
    super.initState();
    _albumArtAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _controller = SmartPlayerController(
      config: SmartPlayerConfig.network(
        widget.audioUrl,
        autoPlay: true,
        enableBackgroundPlayback: widget.enableBackgroundPlayback,
        onComplete: widget.onComplete,
      ),
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    _albumArtAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        switch (widget.style) {
          case AudioPlayerStyle.full:
            return _FullAudioPlayer(
              controller: _controller,
              theme: _theme,
              title: widget.title,
              artist: widget.artist,
              coverUrl: widget.coverUrl,
              albumArtAnimation: _albumArtAnimation,
            );
          case AudioPlayerStyle.compact:
            return _CompactAudioPlayer(
              controller: _controller,
              theme: _theme,
              title: widget.title,
              artist: widget.artist,
              coverUrl: widget.coverUrl,
            );
          case AudioPlayerStyle.minimal:
            return _MinimalAudioControls(
              controller: _controller,
              theme: _theme,
            );
        }
      },
    );
  }
}

class _FullAudioPlayer extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final String? title;
  final String? artist;
  final String? coverUrl;
  final AnimationController albumArtAnimation;

  const _FullAudioPlayer({
    required this.controller,
    required this.theme,
    this.title,
    this.artist,
    this.coverUrl,
    required this.albumArtAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    // Pause album art rotation jab audio pause ho
    if (value.isPlaying) {
      albumArtAnimation.repeat();
    } else {
      albumArtAnimation.stop();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album art (rotating disc)
          RotationTransition(
            turns: albumArtAnimation,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade800,
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
                image: coverUrl != null
                    ? DecorationImage(
                  image: NetworkImage(coverUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: coverUrl == null
                  ? Icon(Icons.music_note,
                  size: 80, color: theme.primaryColor)
                  : null,
            ),
          ),
          const SizedBox(height: 32),
          // Title
          if (title != null)
            Text(
              title!,
              style: theme.titleTextStyle.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (artist != null) ...[
            const SizedBox(height: 6),
            Text(
              artist!,
              style: theme.timeTextStyle.copyWith(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          // Progress bar
          SmartProgressBar(controller: controller, theme: theme),
          const SizedBox(height: 16),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Seek back 15s
              IconButton(
                icon: Icon(Icons.replay_10, color: theme.iconColor, size: 32),
                onPressed: () => controller.seekBackward(10),
              ),
              // Play / Pause
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                  iconSize: 60,
                  onPressed: controller.togglePlayPause,
                ),
              ),
              // Seek forward 15s
              IconButton(
                icon: Icon(Icons.forward_30, color: theme.iconColor, size: 32),
                onPressed: () => controller.seekForward(30),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Speed selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.speed, color: theme.iconColor, size: 18),
              const SizedBox(width: 8),
              DropdownButton<double>(
                value: value.playbackSpeed,
                dropdownColor: Colors.grey.shade900,
                style: TextStyle(color: theme.iconColor),
                underline: const SizedBox(),
                items: [0.75, 1.0, 1.25, 1.5, 2.0]
                    .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s == 1.0 ? 'Normal' : '${s}x',
                    style: TextStyle(color: theme.iconColor),
                  ),
                ))
                    .toList(),
                onChanged: (s) {
                  if (s != null) controller.setPlaybackSpeed(s);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactAudioPlayer extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final String? title;
  final String? artist;
  final String? coverUrl;

  const _CompactAudioPlayer({
    required this.controller,
    required this.theme,
    this.title,
    this.artist,
    this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Small cover
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 44,
                  height: 44,
                  color: Colors.grey.shade800,
                  child: coverUrl != null
                      ? Image.network(coverUrl!, fit: BoxFit.cover)
                      : Icon(Icons.music_note, color: theme.primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              // Title + artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(title!, style: theme.titleTextStyle,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (artist != null)
                      Text(artist!, style: theme.timeTextStyle,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Play/Pause
              IconButton(
                icon: Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: theme.iconColor,
                  size: 28,
                ),
                onPressed: controller.togglePlayPause,
              ),
            ],
          ),
          // Mini progress
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value.progress,
            backgroundColor: theme.progressBarBackgroundColor,
            color: theme.primaryColor,
            minHeight: 2,
          ),
        ],
      ),
    );
  }
}

class _MinimalAudioControls extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;

  const _MinimalAudioControls(
      {required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.replay_10, color: theme.iconColor),
          onPressed: () => controller.seekBackward(10),
        ),
        IconButton(
          icon: Icon(
            value.isPlaying ? Icons.pause_circle : Icons.play_circle,
            color: theme.primaryColor,
            size: 48,
          ),
          onPressed: controller.togglePlayPause,
        ),
        IconButton(
          icon: Icon(Icons.forward_30, color: theme.iconColor),
          onPressed: () => controller.seekForward(30),
        ),
      ],
    );
  }
}