import 'package:flutter/material.dart';
import '../../smart_player_kit.dart';

class NetflixControls extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final String? title;
  final String? subtitle;
  final bool isFullscreen;
  final VoidCallback? onFullscreenToggle;
  final VoidCallback? onNextEpisode;
  final VoidCallback? onPrevEpisode;

  /// ✅ Developer apna custom subtitle UI dena chahta hai toh ye callback pass karo
  /// Agar null hai toh default _SubtitlePanel bottom sheet open hoga
  final VoidCallback? onSubtitleTap;

  const NetflixControls({
    super.key,
    required this.controller,
    required this.theme,
    this.title,
    this.subtitle,
    this.isFullscreen = false,
    this.onFullscreenToggle,
    this.onNextEpisode,
    this.onPrevEpisode,
    this.onSubtitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return AnimatedOpacity(
          opacity: controller.controlsVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !controller.controlsVisible,
            child: Container(
              // Full black scrim
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.25, 0.65, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Top bar ──
                    _NetflixTopBar(
                      title: title,
                      subtitle: subtitle,
                      isFullscreen: isFullscreen,
                      onBack: onFullscreenToggle ?? () => Navigator.maybePop(context),
                      controller: controller,
                      onSubtitleTap: onSubtitleTap, // ✅ pass kiya
                    ),

                    // ── Center controls — yahan play/pause hoga ──
                    Expanded(
                      child: _NetflixCenter(
                        controller: controller,
                        theme: theme,
                        onPrev: onPrevEpisode,
                        onNext: onNextEpisode,
                      ),
                    ),

                    // ── Bottom: seekbar + icons ──
                    _NetflixBottom(
                      controller: controller,
                      theme: theme,
                      isFullscreen: isFullscreen,
                      onFullscreenToggle: onFullscreenToggle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _NetflixTopBar extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool isFullscreen;
  final VoidCallback onBack;
  final SmartPlayerController controller;
  final VoidCallback? onSubtitleTap; // ✅ developer ka custom callback

  const _NetflixTopBar({
    this.title,
    this.subtitle,
    required this.isFullscreen,
    required this.onBack,
    required this.controller,
    this.onSubtitleTap,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(title!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Cast icon
          const Icon(Icons.cast, color: Colors.white, size: 22),
          const SizedBox(width: 16),
          // ✅ Subtitle icon — developer ka callback hai toh woh use karo
          // warna default _SubtitlePanel open karo
          GestureDetector(
            onTap: onSubtitleTap ?? () => _showSubtitlePanel(context),
            child: Icon(
              Icons.subtitles_outlined,
              color: controller.subtitleController.isEnabled
                  ? Colors.white
                  : Colors.white38,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  void _showSubtitlePanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _SubtitlePanel(
        subtitleController: controller.subtitleController,
        playerController: controller,
      ),
    );
  }
}

// ─── Center Controls ──────────────────────────────────────────────────────────

class _NetflixCenter extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _NetflixCenter({
    required this.controller,
    required this.theme,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.value;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Prev / -30s
          _NfBtn(
            icon: Icons.skip_previous_rounded,
            size: 32,
            onTap: onPrev ?? () => controller.seekBackward(30),
          ),
          const SizedBox(width: 28),

          // Seek back 10s
          _NfBtn(
            icon: Icons.replay_10_rounded,
            size: 38,
            onTap: () => controller.seekBackward(10),
          ),
          const SizedBox(width: 20),

          // ── Main Play/Pause button ──
          if (value.isBuffering)
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                  color: theme.primaryColor, strokeWidth: 3),
            )
          else
            GestureDetector(
              onTap: controller.togglePlayPause,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.black38,
                ),
                child: Icon(
                  // ✅ Fix: correct icons
                  value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          const SizedBox(width: 20),

          // Seek forward 10s
          _NfBtn(
            icon: Icons.forward_10_rounded,
            size: 38,
            onTap: () => controller.seekForward(10),
          ),
          const SizedBox(width: 28),

          // Next / +30s
          _NfBtn(
            icon: Icons.skip_next_rounded,
            size: 32,
            onTap: onNext ?? () => controller.seekForward(30),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

class _NetflixBottom extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final bool isFullscreen;
  final VoidCallback? onFullscreenToggle;

  const _NetflixBottom({
    required this.controller,
    required this.theme,
    required this.isFullscreen,
    this.onFullscreenToggle,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Fix: sirf SmartProgressBar — uske andar time labels already hain
          SmartProgressBar(controller: controller, theme: theme),
          const SizedBox(height: 4),

          // Icons row
          Row(
            children: [
              // Volume
              GestureDetector(
                onTap: controller.toggleMute,
                child: Icon(
                  value.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white, size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Speed
              GestureDetector(
                onTap: () => _showSpeedSheet(context),
                child: Text(
                  '${value.playbackSpeed == value.playbackSpeed.truncateToDouble() ? value.playbackSpeed.toInt() : value.playbackSpeed}x',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const Spacer(),
              // ✅ Fix: Fullscreen button properly wired
              GestureDetector(
                onTap: onFullscreenToggle,
                child: Icon(
                  isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white, size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSpeedSheet(BuildContext context) {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Playback Speed',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: speeds.map((s) {
                final sel = controller.value.playbackSpeed == s;
                return GestureDetector(
                  onTap: () {
                    controller.setPlaybackSpeed(s);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFE50914)
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s == 1.0 ? 'Normal' : '${s}x',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: sel
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Ghost Button ─────────────────────────────────────────────────────────────

class _NfBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _NfBtn({required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: size, color: Colors.white,
          shadows: const [Shadow(blurRadius: 8, color: Colors.black87)]),
    );
  }
}

// ─── Subtitle Panel ───────────────────────────────────────────────────────────

class _SubtitlePanel extends StatelessWidget {
  final SubtitleController subtitleController;
  final SmartPlayerController playerController;

  const _SubtitlePanel({
    required this.subtitleController,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: subtitleController,
      builder: (context, _) {
        final hasTracks = subtitleController.hasSubtitles;
        final hasInlineCues = subtitleController.cueCount > 0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.subtitles, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Subtitles / CC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Active badge
                  if (subtitleController.isEnabled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('ON',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),

              // Off option
              _SubTile(
                label: 'Off',
                isSelected: !subtitleController.isEnabled,
                onTap: () {
                  subtitleController.disable();
                  Navigator.pop(context);
                },
              ),

              // Inline cues option (parseAndLoad se aaya)
              if (hasInlineCues && !hasTracks)
                _SubTile(
                  label: 'Default Subtitles',
                  sublabel: '${subtitleController.cueCount} cues loaded',
                  isSelected: subtitleController.isEnabled,
                  onTap: () {
                    // ✅ Fix: activeIndex 0 set karo — cues already hain
                    if (!subtitleController.isEnabled) {
                      subtitleController.enableInline();
                    }
                    Navigator.pop(context);
                  },
                ),

              // Track list (SubtitleTrack se aaya)
              if (hasTracks) ...[
                const Divider(color: Colors.white12),
                ...List.generate(subtitleController.tracks.length, (i) {
                  final track = subtitleController.tracks[i];
                  return _SubTile(
                    label: track.label,
                    sublabel: track.languageCode.toUpperCase(),
                    isSelected: subtitleController.activeIndex == i,
                    isLoading: subtitleController.isLoading &&
                        subtitleController.activeIndex == i,
                    onTap: () {
                      subtitleController.selectTrack(i);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _SubTile extends StatelessWidget {
  final String label;
  final String? sublabel;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  const _SubTile({
    required this.label,
    this.sublabel,
    required this.isSelected,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: isLoading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: Color(0xFFE50914)),
      )
          : Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? const Color(0xFFE50914) : Colors.white38,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: sublabel != null
          ? Text(sublabel!,
          style:
          const TextStyle(color: Colors.white38, fontSize: 11))
          : null,
      onTap: onTap,
    );
  }
}