import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../controller/smart_player_config.dart';
import '../controller/smart_player_controller.dart';
import '../theme/smart_player_theme.dart';

/// Reel item model
class ReelItem {
  final String videoUrl;
  final String? thumbnailUrl;
  final String? title;
  final String? authorName;
  final String? authorAvatar;
  final String? description;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const ReelItem({
    required this.videoUrl,
    this.thumbnailUrl,
    this.title,
    this.authorName,
    this.authorAvatar,
    this.description,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });
}

/// TikTok/Reels style vertical scroll player
///
/// Usage:
/// ```dart
/// SmartReelsPlayer(
///   videos: [
///     ReelItem(videoUrl: 'https://...'),
///     ReelItem(videoUrl: 'https://...'),
///   ],
/// )
/// ```
class SmartReelsPlayer extends StatefulWidget {
  final List<ReelItem> videos;
  final SmartPlayerTheme? theme;

  /// Reel change hone par callback
  final void Function(int index, ReelItem item)? onReelChanged;

  /// Like button press par callback
  final void Function(int index, ReelItem item)? onLike;

  /// Comment button press par callback
  final void Function(int index, ReelItem item)? onComment;

  /// Share button press par callback
  final void Function(int index, ReelItem item)? onShare;

  const SmartReelsPlayer({
    super.key,
    required this.videos,
    this.theme,
    this.onReelChanged,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  State<SmartReelsPlayer> createState() => _SmartReelsPlayerState();
}

class _SmartReelsPlayerState extends State<SmartReelsPlayer> {
  final PageController _pageController = PageController();
  final Map<int, SmartPlayerController> _controllers = {};
  int _currentIndex = 0;

  SmartPlayerTheme get _theme => widget.theme ?? const SmartPlayerTheme();

  @override
  void initState() {
    super.initState();
    // Pehle 2 videos preload karo
    _initController(0);
    if (widget.videos.length > 1) _initController(1);
  }

  void _initController(int index) {
    if (index < 0 || index >= widget.videos.length) return;
    if (_controllers.containsKey(index)) return;

    final item = widget.videos[index];
    final ctrl = SmartPlayerController(
      config: SmartPlayerConfig.network(
        item.videoUrl,
        autoPlay: index == 0,
        resumePlayback: false,
      ),
    );
    _controllers[index] = ctrl;
    ctrl.initialize();
  }

  void _disposeController(int index) {
    final ctrl = _controllers.remove(index);
    ctrl?.dispose();
  }

  void _onPageChanged(int index) {
    // Pehle wala pause karo
    _controllers[_currentIndex]?.pause();

    _currentIndex = index;

    // Naya wala play karo
    _controllers[index]?.play();

    // Agle wale ko preload karo
    _initController(index + 1);

    // 2 se zyada pehle wale dispose karo (memory ke liye)
    if (index > 2) {
      _disposeController(index - 3);
    }

    widget.onReelChanged?.call(index, widget.videos[index]);
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: _onPageChanged,
      itemCount: widget.videos.length,
      itemBuilder: (context, index) {
        final item = widget.videos[index];
        final ctrl = _controllers[index];
        return _ReelPage(
          item: item,
          controller: ctrl,
          theme: _theme,
          isActive: index == _currentIndex,
          onLike: () => widget.onLike?.call(index, item),
          onComment: () => widget.onComment?.call(index, item),
          onShare: () => widget.onShare?.call(index, item),
        );
      },
    );
  }
}

class _ReelPage extends StatefulWidget {
  final ReelItem item;
  final SmartPlayerController? controller;
  final SmartPlayerTheme theme;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const _ReelPage({
    required this.item,
    required this.controller,
    required this.theme,
    required this.isActive,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> {
  bool _isMuted = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video background
        GestureDetector(
          onTap: () {
            widget.controller?.togglePlayPause();
          },
          child: Container(
            color: Colors.black,
            child: _buildVideoSurface(),
          ),
        ),

        // Gradient overlay (bottom)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Right side action buttons
        Positioned(
          right: 12,
          bottom: 100,
          child: _ActionButtons(
            item: widget.item,
            theme: widget.theme,
            isMuted: _isMuted,
            onLike: widget.onLike,
            onComment: widget.onComment,
            onShare: widget.onShare,
            onMuteToggle: () {
              setState(() {
                _isMuted = !_isMuted;
                widget.controller?.toggleMute();
              });
            },
          ),
        ),

        // Bottom content — author + description
        Positioned(
          left: 16,
          right: 80,
          bottom: 40,
          child: _BottomContent(item: widget.item),
        ),
      ],
    );
  }

  Widget _buildVideoSurface() {
    final ctrl = widget.controller;
    if (ctrl == null || ctrl.videoController == null) {
      // Thumbnail fallback
      if (widget.item.thumbnailUrl != null) {
        return Image.network(
          widget.item.thumbnailUrl!,
          fit: BoxFit.cover,
        );
      }
      return const ColoredBox(color: Colors.black);
    }

    return ListenableBuilder(
      listenable: ctrl,
      builder: (_, __) {
        if (!ctrl.value.isInitialized) {
          return widget.item.thumbnailUrl != null
              ? Image.network(widget.item.thumbnailUrl!, fit: BoxFit.cover)
              : const ColoredBox(color: Colors.black);
        }
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: ctrl.videoController!.value.size.width,
              height: ctrl.videoController!.value.size.height,
              child: VideoPlayer(ctrl.videoController!),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ReelItem item;
  final SmartPlayerTheme theme;
  final bool isMuted;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onMuteToggle;

  const _ActionButtons({
    required this.item,
    required this.theme,
    required this.isMuted,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onMuteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Author avatar
        if (item.authorAvatar != null) ...[
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(item.authorAvatar!),
          ),
          const SizedBox(height: 16),
        ],
        // Like
        _ActionIcon(
          icon: item.isLiked ? Icons.favorite : Icons.favorite_border,
          label: _formatCount(item.likeCount),
          color: item.isLiked ? Colors.red : Colors.white,
          onTap: onLike,
        ),
        const SizedBox(height: 20),
        // Comment
        _ActionIcon(
          icon: Icons.comment,
          label: _formatCount(item.commentCount),
          color: Colors.white,
          onTap: onComment,
        ),
        const SizedBox(height: 20),
        // Share
        _ActionIcon(
          icon: Icons.share,
          label: 'Share',
          color: Colors.white,
          onTap: onShare,
        ),
        const SizedBox(height: 20),
        // Mute
        _ActionIcon(
          icon: isMuted ? Icons.volume_off : Icons.volume_up,
          label: '',
          color: Colors.white,
          onTap: onMuteToggle,
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black54)]),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomContent extends StatelessWidget {
  final ReelItem item;

  const _BottomContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.authorName != null)
          Text(
            '@${item.authorName}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
            ),
          ),
        if (item.description != null) ...[
          const SizedBox(height: 4),
          Text(
            item.description!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}