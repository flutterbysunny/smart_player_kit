import 'package:flutter/material.dart';
import '../../smart_player_kit.dart';

/// YouTube-style controls
class YouTubeControls extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final String? title;
  final bool isFullscreen;
  final VoidCallback? onFullscreenToggle;

  const YouTubeControls({
    super.key,
    required this.controller,
    required this.theme,
    this.title,
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
          duration: const Duration(milliseconds: 250),
          // ✅ Fix: IgnorePointer jab controls chhupe hoon
          child: IgnorePointer(
            ignoring: !controller.controlsVisible,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha:0.7),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha:0.8),
                  ],
                  stops: const [0.0, 0.25, 0.65, 1.0],
                ),
              ),
              child: Column(
                children: [
                  // Top bar
                  _TopBar(
                    title: title,
                    controller: controller,
                    theme: theme,
                    isFullscreen: isFullscreen,
                    onFullscreenToggle: onFullscreenToggle,
                  ),
                  // Center controls
                  Expanded(
                    child: _CenterControls(controller: controller, theme: theme),
                  ),
                  // Bottom controls
                  _BottomBar(
                    controller: controller,
                    theme: theme,
                    isFullscreen: isFullscreen,
                    onFullscreenToggle: onFullscreenToggle,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String? title;
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final bool isFullscreen;
  final VoidCallback? onFullscreenToggle;

  const _TopBar({
    required this.title,
    required this.controller,
    required this.theme,
    required this.isFullscreen,
    this.onFullscreenToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        child: Row(
          children: [
            // Back button — fullscreen mein
            if (isFullscreen)
              IconButton(
                icon: Icon(Icons.arrow_back, color: theme.iconColor),
                onPressed: onFullscreenToggle,
              ),
            // Title
            if (title != null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: isFullscreen ? 0 : 12),
                  child: Text(
                    title!,
                    style: theme.titleTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ─── Center Controls ──────────────────────────────────────────────────────────

class _CenterControls extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;

  const _CenterControls({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Seek back
        _CtrlBtn(
          icon: Icons.replay_10,
          size: 36,
          color: theme.iconColor,
          onTap: () => controller.seekBackward(10),
        ),
        const SizedBox(width: 28),
        // Play / Pause / Buffer
        if (value.isBuffering)
          SizedBox(
            width: theme.playButtonSize,
            height: theme.playButtonSize,
            child: CircularProgressIndicator(
              color: theme.primaryColor,
              strokeWidth: 3,
            ),
          )
        else
          _CtrlBtn(
            icon: value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            size: theme.playButtonSize,
            color: theme.iconColor,
            onTap: controller.togglePlayPause,
          ),
        const SizedBox(width: 28),
        // Seek forward
        _CtrlBtn(
          icon: Icons.forward_10,
          size: 36,
          color: theme.iconColor,
          onTap: () => controller.seekForward(10),
        ),
      ],
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final bool isFullscreen;
  final VoidCallback? onFullscreenToggle;

  const _BottomBar({
    required this.controller,
    required this.theme,
    required this.isFullscreen,
    this.onFullscreenToggle,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seekbar
          SmartProgressBar(controller: controller, theme: theme),
          // Icon row
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Row(
              children: [
                // Volume / Mute
                IconButton(
                  icon: Icon(
                    value.isMuted ? Icons.volume_off : Icons.volume_up,
                    color: theme.iconColor,
                    size: theme.iconSize,
                  ),
                  onPressed: controller.toggleMute,
                ),
                const Spacer(),
                // Speed
                if (controller.config.allowSpeedControl)
                  GestureDetector(
                    onTap: () => _showSpeedSheet(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Text(
                        '${value.playbackSpeed == value.playbackSpeed.truncateToDouble() ? value.playbackSpeed.toInt() : value.playbackSpeed}x',
                        style: theme.timeTextStyle,
                      ),
                    ),
                  ),
                // Fullscreen toggle
                if (controller.config.allowFullscreen)
                  IconButton(
                    icon: Icon(
                      isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: theme.iconColor,
                      size: theme.iconSize,
                    ),
                    onPressed: onFullscreenToggle,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSpeedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _SpeedSheet(controller: controller, theme: theme),
    );
  }
}

// ─── Speed Sheet ──────────────────────────────────────────────────────────────

class _SpeedSheet extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;

  const _SpeedSheet({required this.controller, required this.theme});

  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  Widget build(BuildContext context) {
    final current = controller.value.playbackSpeed;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Playback Speed', style: theme.titleTextStyle),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _speeds.map((s) {
              final selected = current == s;
              return GestureDetector(
                onTap: () {
                  controller.setPlaybackSpeed(s);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? theme.primaryColor : Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s == 1.0 ? 'Normal' : '${s}x',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;

  const _CtrlBtn({
    required this.icon,
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: size, color: color,
          shadows: const [Shadow(blurRadius: 6, color: Colors.black54)]),
    );
  }
}