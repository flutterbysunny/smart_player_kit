import 'package:flutter/material.dart';
import '../../smart_player_kit.dart';

/// Custom seekbar with buffer indicator
class SmartProgressBar extends StatefulWidget {
  final SmartPlayerController controller;
  final SmartPlayerTheme theme;

  const SmartProgressBar({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  State<SmartProgressBar> createState() => _SmartProgressBarState();
}

class _SmartProgressBarState extends State<SmartProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SmartPlayerValue>(
      valueListenable: widget.controller,
      builder: (_, value, __) {
        final progress = _isDragging ? _dragValue : value.progress;
        final buffer = value.bufferProgress;

        final position = _isDragging
            ? Duration(
          milliseconds:
          (_dragValue * value.duration.inMilliseconds).toInt(),
        )
            : value.position;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Time labels ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: widget.theme.timeTextStyle,
                  ),
                  Text(
                    _formatDuration(value.duration),
                    style: widget.theme.timeTextStyle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Progress bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,

                    // Drag seek
                    onHorizontalDragStart: (_) {
                      setState(() => _isDragging = true);
                    },
                    onHorizontalDragUpdate: (details) {
                      final dx = details.localPosition.dx;
                      setState(() {
                        _dragValue = (dx / width).clamp(0.0, 1.0);
                      });
                    },
                    onHorizontalDragEnd: (_) async {
                      final ms =
                          widget.controller.value.duration.inMilliseconds;
                      final newPos = Duration(
                          milliseconds: (_dragValue * ms).toInt());
                      await widget.controller.seekTo(newPos);
                      if (mounted) setState(() => _isDragging = false);
                    },

                    // Tap seek — tumhara addition ✅
                    onTapDown: (details) async {
                      final dx = details.localPosition.dx;
                      final tapValue = (dx / width).clamp(0.0, 1.0);
                      final ms =
                          widget.controller.value.duration.inMilliseconds;
                      final newPos = Duration(
                          milliseconds: (tapValue * ms).toInt());
                      await widget.controller.seekTo(newPos);
                    },

                    child: SizedBox(
                      height: 24, // bada touch area
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Background track
                          Container(
                            height: widget.theme.progressBarHeight,
                            decoration: BoxDecoration(
                              color: widget.theme.progressBarBackgroundColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),

                          // Buffer progress
                          FractionallySizedBox(
                            widthFactor: buffer.clamp(0.0, 1.0),
                            child: Container(
                              height: widget.theme.progressBarHeight,
                              decoration: BoxDecoration(
                                color: widget.theme.bufferColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),

                          // Played progress
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: widget.theme.progressBarHeight,
                              decoration: BoxDecoration(
                                color: widget.theme.progressBarColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),

                          // Thumb
                          Positioned(
                            left: ((width * progress.clamp(0.0, 1.0)) - 8)
                                .clamp(0.0, width - 16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: _isDragging ? 16 : 12,
                              height: _isDragging ? 16 : 12,
                              decoration: BoxDecoration(
                                color: widget.theme.progressBarColor,
                                shape: BoxShape.circle,
                                boxShadow: _isDragging
                                    ? [
                                  BoxShadow(
                                    color: widget.theme.progressBarColor
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ]
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}