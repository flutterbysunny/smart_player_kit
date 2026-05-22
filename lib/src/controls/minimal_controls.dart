import 'package:flutter/material.dart';

import '../../smart_player_kit.dart';
import 'progress_bar.dart';

/// Minimal controls — clean, distraction-free
/// Sirf: play/pause + seekbar + fullscreen
/// Course apps aur clean video embeds ke liye perfect
class MinimalControls extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final bool isFullscreen;
  final VoidCallback? onFullscreenToggle;

  const MinimalControls({
    super.key,
    required this.controller,
    required this.theme,
    this.isFullscreen = false,
    this.onFullscreenToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return AnimatedOpacity(
          opacity: controller.controlsVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !controller.controlsVisible,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Very subtle scrim — barely visible
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),

                // Center — just play/pause + buffering
                Center(child: _MinimalCenter(controller: controller, theme: theme)),

                // Bottom — seekbar + minimal icons
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: _MinimalBottom(
                      controller: controller,
                      theme: theme,
                      isFullscreen: isFullscreen,
                      onFullscreenToggle: onFullscreenToggle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MinimalCenter extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;

  const _MinimalCenter({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    if (value.isBuffering) {
      return SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }
    // Only show on pause — during play no center button (clean look)
    if (value.isPlaying) return const SizedBox.shrink();

    return GestureDetector(
      onTap: controller.togglePlayPause,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        ),
        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
      ),
    );
  }
}

class _MinimalBottom extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final bool isFullscreen;
  final VoidCallback? onFullscreenToggle;

  const _MinimalBottom({
    required this.controller,
    required this.theme,
    required this.isFullscreen,
    this.onFullscreenToggle,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seekbar
          SmartProgressBar(controller: controller, theme: theme),
          const SizedBox(height: 2),
          // Single compact row
          Row(
            children: [
              // Play/Pause small
              GestureDetector(
                onTap: controller.togglePlayPause,
                child: Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              // Time
              Text(
                '${_fmt(value.position)} / ${_fmt(value.duration)}',
                style: theme.timeTextStyle.copyWith(fontSize: 11),
              ),
              const Spacer(),
              // Mute
              GestureDetector(
                onTap: controller.toggleMute,
                child: Icon(
                  value.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              // Fullscreen
              GestureDetector(
                onTap: onFullscreenToggle,
                child: Icon(
                  isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}