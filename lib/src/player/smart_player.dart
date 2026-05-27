import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../smart_player_kit.dart';


class SmartPlayer extends StatefulWidget {
  final String? url;
  final SmartPlayerConfig? config;
  final SmartPlayerController? controller;
  final double? height;
  final String? title;
  final String? subtitle;

  const SmartPlayer({
    super.key,
    required String this.url,
    this.height,
    this.title,
    this.subtitle,
  })  : config = null,
        controller = null;

  const SmartPlayer.config(
      SmartPlayerConfig config, {
        super.key,
        this.height,
        this.title,
        this.subtitle,
        this.controller,
      })  : url = null,
        config = config;

  static Widget network(String url, {
    Key? key, double? height, String? title,
    bool resumePlayback = false,
    SmartPlayerTheme? theme,
    VoidCallback? onComplete,
  }) => SmartPlayer.config(
    SmartPlayerConfig.network(url,
        resumePlayback: resumePlayback, theme: theme, onComplete: onComplete),
    key: key, height: height, title: title,
  );

  static Widget hls(String url, {
    Key? key, double? height, String? title,
    bool resumePlayback = false, SmartPlayerTheme? theme,
  }) => SmartPlayer.config(
    SmartPlayerConfig.hls(url, resumePlayback: resumePlayback, theme: theme),
    key: key, height: height, title: title,
  );

  @override
  State<SmartPlayer> createState() => _SmartPlayerState();
}

class _SmartPlayerState extends State<SmartPlayer> {
  late SmartPlayerController _controller;
  bool _isExternal = false;

  SmartPlayerConfig get _config =>
      widget.config ?? SmartPlayerConfig.network(widget.url!);
  SmartPlayerTheme get _theme => _config.theme ?? const SmartPlayerTheme();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isExternal = true;
    } else {
      _controller = SmartPlayerController(config: _config);
      _controller.initialize();
    }
  }

  @override
  void dispose() {
    if (!_isExternal) _controller.dispose();
    super.dispose();
  }

  // ✅ Fix: Fullscreen — Navigator.push se naya Scaffold, landscape force karo
  Future<void> _enterFullscreen() async {
    // Pehle landscape set karo
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (!mounted) return;

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (ctx, _, __) => _FullscreenPage(
          controller: _controller,
          theme: _theme,
          title: widget.title,
          subtitle: widget.subtitle,
          onExit: _exitFullscreen,
        ),
      ),
    );
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final ratio = _controller.value.aspectRatio > 0
            ? _controller.value.aspectRatio
            : 16 / 9;
        return AspectRatio(
          aspectRatio: ratio,
          child: _PlayerSurface(
            controller: _controller,
            theme: _theme,
            title: widget.title,
            subtitle: widget.subtitle,
            isFullscreen: false,
            onFullscreen: _enterFullscreen,
          ),
        );
      },
    );
  }
}

// ─── Fullscreen Page ──────────────────────────────────────────────────────────

class _FullscreenPage extends StatefulWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final String? title;
  final String? subtitle;
  final VoidCallback onExit;

  const _FullscreenPage({
    required this.controller,
    required this.theme,
    this.title,
    this.subtitle,
    required this.onExit,
  });

  @override
  State<_FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<_FullscreenPage> {
  @override
  void dispose() {
    // Page pop hone par portrait restore karo
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // ✅ Fix: WillPopScope se back gesture pe bhi portrait restore ho
      body: PopScope(
        onPopInvoked: (_) {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        },
        child: _PlayerSurface(
          controller: widget.controller,
          theme: widget.theme,
          title: widget.title,
          subtitle: widget.subtitle,
          isFullscreen: true,
          onFullscreen: widget.onExit,
        ),
      ),
    );
  }
}

// ─── Player Surface ───────────────────────────────────────────────────────────

class _PlayerSurface extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;
  final String? title;
  final String? subtitle;
  final bool isFullscreen;
  final VoidCallback onFullscreen;

  const _PlayerSurface({
    required this.controller,
    required this.theme,
    this.title,
    this.subtitle,
    required this.isFullscreen,
    required this.onFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final value = controller.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(theme.playerBorderRadius),
          child: ColoredBox(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Video ──
                _VideoSurface(controller: controller),

                // ── Gesture layer ──
                SmartGestureDetector(
                  controller: controller,
                  child: const SizedBox.expand(),
                ),

                // ── Controls ──
                if (value.isInitialized)
                  _buildControls(context),

                // ── Subtitle overlay — seekbar ke upar ──
                // isInitialized check kaafi hai — overlay khud null cue handle karta hai
                if (value.isInitialized)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: isFullscreen ? 80 : 60,
                    child: SubtitleOverlay(
                      subtitleController: controller.subtitleController,
                      theme: theme,
                      bottomOffset: 0,
                    ),
                  ),

                // ── Buffering ──
                if (value.isBuffering)
                  Center(
                    child: CircularProgressIndicator(
                        color: theme.primaryColor, strokeWidth: 3),
                  ),

                // ── Error ──
                if (value.hasError)
                  _ErrorWidget(
                      value: value, theme: theme, controller: controller),

                // ── Completed ──
                if (value.isCompleted)
                  _CompletedWidget(controller: controller, theme: theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    switch (controller.config.controlsStyle) {
      case SmartPlayerControlsStyle.netflix:
        return NetflixControls(
          controller: controller,
          theme: SmartPlayerTheme.netflix(),
          title: title,
          subtitle: subtitle,
          isFullscreen: isFullscreen,
          onFullscreenToggle: onFullscreen,
          onSubtitleTap: controller.config.onSubtitleTap,
        );
      case SmartPlayerControlsStyle.minimal:
        return MinimalControls(
          controller: controller,
          theme: SmartPlayerTheme.minimal(),
          isFullscreen: isFullscreen,
          onFullscreenToggle: onFullscreen,
        );
      case SmartPlayerControlsStyle.reels:
      case SmartPlayerControlsStyle.none:
        return const SizedBox.shrink();
      case SmartPlayerControlsStyle.youtube:
        return YouTubeControls(
          controller: controller,
          theme: theme,
          title: title,
          isFullscreen: isFullscreen,
          onFullscreenToggle: onFullscreen,
        );
    }
  }
}

// ─── Video Surface ────────────────────────────────────────────────────────────

class _VideoSurface extends StatelessWidget {
  final SmartPlayerController controller;
  const _VideoSurface({required this.controller});

  @override
  Widget build(BuildContext context) {
    final vc = controller.videoController;
    final cfg = controller.config;

    if (vc == null || !controller.value.isInitialized) {
      if (cfg.placeholder != null) return cfg.placeholder!;
      if (cfg.thumbnailUrl != null) {
        return Image.network(cfg.thumbnailUrl!, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink());
      }
      return const SizedBox.shrink();
    }

    // ✅ Fix: FittedBox nahi — Center + AspectRatio = no assertion error
    return Center(
      child: AspectRatio(
        aspectRatio: vc.value.aspectRatio,
        child: VideoPlayer(vc),
      ),
    );
  }
}

// ─── Error Widget ─────────────────────────────────────────────────────────────

class _ErrorWidget extends StatelessWidget {
  final SmartPlayerValue value;
  final SmartPlayerTheme theme;
  final SmartPlayerController controller;

  const _ErrorWidget({
    required this.value,
    required this.theme,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 12),
            Text('Video load nahi hua', style: theme.titleTextStyle),
            if (value.errorMessage != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  value.errorMessage!,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.initialize,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Completed Widget ─────────────────────────────────────────────────────────

class _CompletedWidget extends StatelessWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;

  const _CompletedWidget({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                controller.seekTo(Duration.zero);
                controller.play();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    color: Colors.white24, shape: BoxShape.circle),
                child: Icon(Icons.replay, color: theme.iconColor, size: 40),
              ),
            ),
            const SizedBox(height: 12),
            Text('Replay', style: theme.titleTextStyle),
          ],
        ),
      ),
    );
  }
}