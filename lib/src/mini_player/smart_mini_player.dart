// lib/src/mini_player/smart_mini_player.dart

import 'package:flutter/material.dart';

import '../../smart_player_kit.dart';

// import '../controller/smart_player_controller.dart';
// import 'mini_player_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SmartMiniPlayer
// ─────────────────────────────────────────────────────────────────────────────

class SmartMiniPlayer extends StatefulWidget {
  const SmartMiniPlayer({
    super.key,
    required this.miniController,
    required this.playerController,
    this.videoWidget,
    this.onExpand,
    this.width = 200.0,
    this.height = 120.0,
    this.edgeMargin = 8.0,
    this.bottomOffset = 80.0,
    this.appearDuration = const Duration(milliseconds: 320),
  });

  final MiniPlayerController miniController;
  final SmartPlayerController playerController;

  /// Actual video widget — VideoPlayer(controller) pass karo
  final Widget? videoWidget;

  /// Tap karne par full player expand hoga
  final VoidCallback? onExpand;

  final double width;
  final double height;
  final double edgeMargin;
  final double bottomOffset;
  final Duration appearDuration;

  @override
  State<SmartMiniPlayer> createState() => _SmartMiniPlayerState();
}

class _SmartMiniPlayerState extends State<SmartMiniPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  Offset _base = Offset.zero;
  bool _baseSet = false;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(vsync: this, duration: widget.appearDuration);

    _scale = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.55)),
    );

    widget.miniController.addListener(_onCtrl);
    _syncAnim(widget.miniController.value.state);
  }

  @override
  void dispose() {
    widget.miniController.removeListener(_onCtrl);
    _anim.dispose();
    super.dispose();
  }

  void _onCtrl() {
    _syncAnim(widget.miniController.value.state);
    if (mounted) setState(() {});
  }

  void _syncAnim(MiniPlayerState state) {
    if (state == MiniPlayerState.minimized) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  void _initBase(Size screen) {
    if (_baseSet) return;
    _baseSet = true;
    _base = Offset(
      screen.width - widget.width - widget.edgeMargin,
      screen.height - widget.height - widget.edgeMargin - widget.bottomOffset,
    );
  }

  Offset _resolvePosition(Offset dragOffset, Size screen) {
    // ✅ Screen size zero hone par safe fallback
    if (screen.width == 0 || screen.height == 0) return Offset.zero;

    final raw = _base + dragOffset;

    final minX = widget.edgeMargin;
    final maxX = screen.width - widget.width - widget.edgeMargin;
    final minY = widget.edgeMargin;
    final maxY = screen.height - widget.height - widget.edgeMargin;

    // ✅ max >= min check — negative hone par edge margin use karo
    return Offset(
      raw.dx.clamp(minX, maxX > minX ? maxX : minX),
      raw.dy.clamp(minY, maxY > minY ? maxY : minY),
    );
  }

  void _togglePlayPause() {
    if (widget.playerController.value.isPlaying) {
      widget.playerController.pause();
    } else {
      widget.playerController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    _initBase(screen);

    return ValueListenableBuilder<MiniPlayerValue>(
      valueListenable: widget.miniController,
      builder: (context, val, _) {
        if (val.isHidden && _anim.isDismissed) return const SizedBox.shrink();

        final pos = _resolvePosition(val.dragOffset, screen);

        return AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            final scale = _scale.value;
            final opacity = _opacity.value.clamp(0.0, 1.0);
            if (scale < 0.01) return const SizedBox.shrink();

            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.bottomRight,
                  child: _MiniCard(
                    playerController: widget.playerController,
                    videoWidget: widget.videoWidget,
                    width: widget.width,
                    height: widget.height,
                    onTap: () {
                      widget.miniController.expand();
                      widget.onExpand?.call();
                    },
                    onClose: widget.miniController.close,
                    onPlayPause: _togglePlayPause,
                    onPanStart: (_) => widget.miniController.onDragStart(),
                    onPanUpdate: (d) => widget.miniController.onDragUpdate(d.delta),
                    onPanEnd: (_) => widget.miniController.onDragEnd(
                      screenSize: screen,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MiniCard — full video + top-left play/pause + top-right close only
// ─────────────────────────────────────────────────────────────────────────────

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.playerController,
    required this.width,
    required this.height,
    required this.onTap,
    required this.onClose,
    required this.onPlayPause,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    this.videoWidget,
  });

  final SmartPlayerController playerController;
  final Widget? videoWidget;
  final double width;
  final double height;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: Material(
        elevation: 14,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Full video / placeholder ─────────────────
              _VideoArea(videoWidget: videoWidget, width: width, height: height),

              // ── Subtle dark gradient — controls readable rahein
              const _Gradient(),

              // ── Top-left: Play / Pause ───────────────────
              Positioned(
                top: 6,
                left: 6,
                child: _PlayPauseBtn(
                  controller: playerController,
                  onTap: onPlayPause,
                ),
              ),

              // ── Top-right: Close ─────────────────────────
              Positioned(
                top: 6,
                right: 6,
                child: _CloseBtn(onTap: onClose),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _VideoArea
// ─────────────────────────────────────────────────────────────────────────────

class _VideoArea extends StatelessWidget {
  const _VideoArea({required this.videoWidget, required this.width, required this.height});
  final Widget? videoWidget;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (videoWidget != null) {
      // ✅ Same VideoPlayerController — live video dikhega
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(width: width, height: height, child: videoWidget),
      );
    }
    // Fallback placeholder
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.movie, color: Colors.white24, size: 32),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Gradient — icons ke peeche halka dark overlay
// ─────────────────────────────────────────────────────────────────────────────

class _Gradient extends StatelessWidget {
  const _Gradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Colors.black.withValues(alpha: 0.55),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PlayPauseBtn — top-left
// ─────────────────────────────────────────────────────────────────────────────

class _PlayPauseBtn extends StatelessWidget {
  const _PlayPauseBtn({required this.controller, required this.onTap});
  final SmartPlayerController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SmartPlayerValue>(
      valueListenable: controller,
      builder: (_, val, __) {
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: Icon(
              val.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CloseBtn — top-right
// ─────────────────────────────────────────────────────────────────────────────

class _CloseBtn extends StatelessWidget {
  const _CloseBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:0.55),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
      ),
    );
  }
}