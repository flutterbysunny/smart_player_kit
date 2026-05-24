import 'package:flutter/material.dart';
import '../../smart_player_kit.dart';
import 'mini_player_controller.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const double _kMiniWidth = 160.0;
const double _kMiniHeight = 90.0;
const double _kMiniRadius = 10.0;
const double _kBottomMargin = 80.0; // BottomNavBar ke upar
const double _kSideMargin = 12.0;
const Duration _kAnimDuration = Duration(milliseconds: 250);
const Curve _kAnimCurve = Curves.easeOutCubic;

// ─── Main Widget ──────────────────────────────────────────────────────────────

/// YouTube-style draggable floating mini player.
///
/// Ye widget [Overlay] ya [Stack] ke andar use karo. Isko screen ke
/// baaki hisse ke upar float karta hai.
///
/// ```dart
/// MiniVideoPlayer(
///   miniController: miniController,
///   playerController: smartPlayerController,
///   videoWidget: YourVideoWidget(),
///   onTap: () => Navigator.push(context, fullPlayerRoute),
/// )
/// ```
class MiniVideoPlayer extends StatefulWidget {
  const MiniVideoPlayer({
    super.key,
    required this.miniController,
    required this.playerController,
    required this.videoWidget,
    this.onTap,
    this.bottomMargin = _kBottomMargin,
    this.sideMargin = _kSideMargin,
  });

  /// Mini player state manager
  final MiniPlayerController miniController;

  /// SmartPlayerController — play/pause ke liye
  final SmartPlayerController playerController;

  /// Actual video widget (video_player ka VideoPlayer, ya youtube_player etc.)
  final Widget videoWidget;

  /// Full player kholne ka callback (tap on mini player)
  final VoidCallback? onTap;

  /// Screen ke bottom se kitna upar rahe
  final double bottomMargin;

  /// Screen ke side se kitna andar rahe
  final double sideMargin;

  @override
  State<MiniVideoPlayer> createState() => _MiniVideoPlayerState();
}

class _MiniVideoPlayerState extends State<MiniVideoPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: _kAnimDuration,
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: _kAnimCurve),
    );

    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    widget.miniController.addListener(_onStateChange);
    _syncAnimation(widget.miniController.value.state);
  }

  @override
  void dispose() {
    widget.miniController.removeListener(_onStateChange);
    _animController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    _syncAnimation(widget.miniController.value.state);
  }

  void _syncAnimation(MiniPlayerState state) {
    if (state == MiniPlayerState.minimized) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  // ─── Gesture handlers ────────────────────────────────────────────────────

  void _handleDragStart(DragStartDetails details) {
    widget.miniController.onDragStart();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    widget.miniController.onDragUpdate(details.delta);
  }

  void _handleDragEnd(DragEndDetails details) {
    final size = MediaQuery.of(context).size;
    widget.miniController.onDragEnd(screenSize: size);
  }

  void _handleTap() {
    widget.miniController.expand();
    widget.onTap?.call();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MiniPlayerValue>(
      valueListenable: widget.miniController,
      builder: (context, miniValue, _) {
        // Hidden state mein kuch mat dikhao
        if (miniValue.isHidden) return const SizedBox.shrink();

        final screenSize = MediaQuery.of(context).size;

        // Base position — bottom-right corner
        double baseRight = widget.sideMargin;
        double baseBottom = widget.bottomMargin;

        // Drag offset apply karo (clamped taaki screen se bahar na jaye)
        final dragDx = -miniValue.dragOffset.dx; // right se measure ho raha
        final dragDy = -miniValue.dragOffset.dy; // bottom se measure ho raha

        final clampedRight = (baseRight + dragDx).clamp(
          widget.sideMargin,
          screenSize.width - _kMiniWidth - widget.sideMargin,
        );
        final clampedBottom = (baseBottom + dragDy).clamp(
          widget.bottomMargin,
          screenSize.height - _kMiniHeight - 40.0,
        );

        return AnimatedPositioned(
          duration: miniValue.isDragging ? Duration.zero : _kAnimDuration,
          curve: _kAnimCurve,
          right: clampedRight,
          bottom: clampedBottom,
          child: FadeTransition(
            opacity: _opacityAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              alignment: Alignment.bottomRight,
              child: _MiniPlayerCard(
                miniValue: miniValue,
                playerController: widget.playerController,
                videoWidget: widget.videoWidget,
                onTap: _handleTap,
                onClose: widget.miniController.close,
                onDragStart: _handleDragStart,
                onDragUpdate: _handleDragUpdate,
                onDragEnd: _handleDragEnd,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Card UI ─────────────────────────────────────────────────────────────────

class _MiniPlayerCard extends StatelessWidget {
  const _MiniPlayerCard({
    required this.miniValue,
    required this.playerController,
    required this.videoWidget,
    required this.onTap,
    required this.onClose,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final MiniPlayerValue miniValue;
  final SmartPlayerController playerController;
  final Widget videoWidget;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: onDragStart,
      onPanUpdate: onDragUpdate,
      onPanEnd: onDragEnd,
      onTap: onTap,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(_kMiniRadius),
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_kMiniRadius),
          child: Container(
            width: _kMiniWidth + 160, // video + info panel
            height: _kMiniHeight,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
            ),
            child: Row(
              children: [
                // ── Video thumbnail / player ──────────────────────────────
                SizedBox(
                  width: _kMiniWidth,
                  height: _kMiniHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      videoWidget,
                      // Drag indicator overlay (subtle)
                      Positioned.fill(
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Info + controls ───────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          miniValue.videoTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (miniValue.videoSubtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            miniValue.videoSubtitle,
                            style: const TextStyle(
                              color: Color(0xFFAAAAAA),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Play/Pause button ─────────────────────────────────────
                _PlayPauseButton(playerController: playerController),

                // ── Close button ──────────────────────────────────────────
                _CloseButton(onClose: onClose),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Play/Pause Button ────────────────────────────────────────────────────────

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.playerController});

  final SmartPlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SmartPlayerValue>(
      valueListenable: playerController,
      builder: (context, playerState, _) {
        final isPlaying = playerState.isPlaying;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (isPlaying) {
              playerController.pause();
            } else {
              playerController.play();
            }
          },
          child: SizedBox(
            width: 40,
            height: _kMiniHeight,
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

// ─── Close Button ─────────────────────────────────────────────────────────────

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClose,
      child: const SizedBox(
        width: 36,
        height: _kMiniHeight,
        child: Icon(
          Icons.close,
          color: Color(0xFFAAAAAA),
          size: 18,
        ),
      ),
    );
  }
}