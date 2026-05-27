import 'package:flutter/material.dart';
import '../controller/smart_player_config.dart';
import '../controller/smart_player_controller.dart';

/// Gesture indicator type
enum _GestureType { none, brightness, volume, seek }

/// Player pe saare gestures handle karta hai:
/// - Double-tap → seek forward/backward
/// - Swipe left → brightness
/// - Swipe right → volume
/// - Pinch → zoom
class SmartGestureDetector extends StatefulWidget {
  final SmartPlayerController controller;
  final Widget child;

  const SmartGestureDetector({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<SmartGestureDetector> createState() => _SmartGestureDetectorState();
}

class _SmartGestureDetectorState extends State<SmartGestureDetector>
    with SingleTickerProviderStateMixin {
  SmartPlayerController get _ctrl => widget.controller;
  SmartPlayerConfig get _cfg => _ctrl.config;

  // Gesture state
  _GestureType _activeGesture = _GestureType.none;
  double _gestureValue = 0.0;
  bool _showIndicator = false;

  // Seek indicator
  bool _seekForward = true;
  int _doubleTapCount = 0;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ─── Tap Handlers ─────────────────────────────────────────────────────────

  void _onTap() {
    _ctrl.toggleControls();
  }

  void _onDoubleTapLeft() {
    if (!_cfg.enableDoubleTapSeek) return;
    _doubleTapCount++;
    _seekForward = false;
    _ctrl.seekBackward(_cfg.doubleTapSeekSeconds);
    _showSeekIndicator(false);
  }

  void _onDoubleTapRight() {
    if (!_cfg.enableDoubleTapSeek) return;
    _doubleTapCount++;
    _seekForward = true;
    _ctrl.seekForward(_cfg.doubleTapSeekSeconds);
    _showSeekIndicator(true);
  }

  void _showSeekIndicator(bool forward) {
    setState(() {
      _activeGesture = _GestureType.seek;
      _showIndicator = true;
      _seekForward = forward;
    });
    _fadeController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _hideIndicator();
        _doubleTapCount = 0;
      }
    });
  }

  // ─── Swipe Handlers ───────────────────────────────────────────────────────

  double _swipeStartY = 0;
  double _swipeStartValue = 0;
  bool _swipeLeft = false;

  void _onVerticalDragStart(DragStartDetails details) {
    final width = context.size?.width ?? 300;
    _swipeLeft = details.localPosition.dx < width / 2;
    _swipeStartY = details.localPosition.dy;

    if (_swipeLeft && _cfg.enableBrightnessGesture) {
      _swipeStartValue = _gestureValue;
      _activeGesture = _GestureType.brightness;
    } else if (!_swipeLeft && _cfg.enableVolumeGesture) {
      _swipeStartValue = _ctrl.value.volume;
      _activeGesture = _GestureType.volume;
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_activeGesture == _GestureType.none) return;

    final height = context.size?.height ?? 200;
    final dy = _swipeStartY - details.localPosition.dy;
    final delta = dy / height;

    setState(() {
      _showIndicator = true;
      if (_activeGesture == _GestureType.volume) {
        final newVol = (_swipeStartValue + delta).clamp(0.0, 1.0);
        _gestureValue = newVol;
        _ctrl.setVolume(newVol);
      } else if (_activeGesture == _GestureType.brightness) {
        _gestureValue = (_swipeStartValue + delta).clamp(0.0, 1.0);
        // Brightness change — screen_brightness package use hoga
        // SmartBrightnessController.setBrightness(_gestureValue);
      }
    });
  }

  void _onVerticalDragEnd(DragEndDetails _) {
    _hideIndicator();
    _activeGesture = _GestureType.none;
  }

  void _hideIndicator() {
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showIndicator = false;
        });
      }
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Double-tap zones
        Row(
          children: [
            // Left zone — seek backward / brightness
            Expanded(
              child: GestureDetector(
                onTap: _onTap,
                onDoubleTap: _onDoubleTapLeft,
                onVerticalDragStart: _onVerticalDragStart,
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            // Right zone — seek forward / volume
            Expanded(
              child: GestureDetector(
                onTap: _onTap,
                onDoubleTap: _onDoubleTapRight,
                onVerticalDragStart: _onVerticalDragStart,
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),

        // Main content
        widget.child,

        // Gesture indicators
        if (_showIndicator)
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildIndicator(),
          ),
      ],
    );
  }

  Widget _buildIndicator() {
    switch (_activeGesture) {
      case _GestureType.seek:
        return _SeekIndicator(
          forward: _seekForward,
          seconds:
          _cfg.doubleTapSeekSeconds * (_doubleTapCount > 0 ? _doubleTapCount : 1),
        );
      case _GestureType.volume:
        return _SwipeIndicator(
          icon: _gestureValue == 0 ? Icons.volume_off : Icons.volume_up,
          value: _gestureValue,
          label: '${(_gestureValue * 100).toInt()}%',
          alignment: Alignment.centerRight,
        );
      case _GestureType.brightness:
        return _SwipeIndicator(
          icon: Icons.brightness_6,
          value: _gestureValue,
          label: '${(_gestureValue * 100).toInt()}%',
          alignment: Alignment.centerLeft,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Indicator Widgets ────────────────────────────────────────────────────────

class _SeekIndicator extends StatelessWidget {
  final bool forward;
  final int seconds;

  const _SeekIndicator({required this.forward, required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: forward ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:0.6),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              forward ? Icons.fast_forward : Icons.fast_rewind,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              '$seconds sec',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeIndicator extends StatelessWidget {
  final IconData icon;
  final double value;
  final String label;
  final Alignment alignment;

  const _SwipeIndicator({
    required this.icon,
    required this.value,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            SizedBox(
              width: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}