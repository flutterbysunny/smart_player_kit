// example/lib/screens/mini_player_demo_screen.dart
//
// SmartMiniPlayer ka complete demo.
// MiniPlayerController (MiniPlayerValue based) + SmartPlayerController use karta hai.

import 'package:flutter/material.dart';

// ─── Stubs (asli package mein yeh already hote hain) ─────────────────────────


enum MiniPlayerState { hidden, minimized, expanded }

class MiniPlayerValue {
  const MiniPlayerValue({
    this.state = MiniPlayerState.hidden,
    this.dragOffset = Offset.zero,
    this.isDragging = false,
    this.videoTitle = '',
    this.videoSubtitle = '',
    this.thumbnailUrl,
  });

  final MiniPlayerState state;
  final Offset dragOffset;
  final bool isDragging;
  final String videoTitle;
  final String videoSubtitle;
  final String? thumbnailUrl;

  bool get isHidden => state == MiniPlayerState.hidden;
  bool get isMinimized => state == MiniPlayerState.minimized;
  bool get isExpanded => state == MiniPlayerState.expanded;

  MiniPlayerValue copyWith({
    MiniPlayerState? state,
    Offset? dragOffset,
    bool? isDragging,
    String? videoTitle,
    String? videoSubtitle,
    String? thumbnailUrl,
  }) =>
      MiniPlayerValue(
        state: state ?? this.state,
        dragOffset: dragOffset ?? this.dragOffset,
        isDragging: isDragging ?? this.isDragging,
        videoTitle: videoTitle ?? this.videoTitle,
        videoSubtitle: videoSubtitle ?? this.videoSubtitle,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      );
}

class MiniPlayerController extends ValueNotifier<MiniPlayerValue> {
  MiniPlayerController() : super(const MiniPlayerValue());

  void openMiniPlayer({
    required String title,
    String subtitle = '',
    String? thumbnailUrl,
  }) {
    value = value.copyWith(
      state: MiniPlayerState.minimized,
      videoTitle: title,
      videoSubtitle: subtitle,
      thumbnailUrl: thumbnailUrl,
      dragOffset: Offset.zero,
    );
  }

  void expand() {
    if (value.isHidden) return;
    value = value.copyWith(
        state: MiniPlayerState.expanded,
        dragOffset: Offset.zero,
        isDragging: false);
  }

  void minimize() {
    if (value.isHidden) return;
    value = value.copyWith(
        state: MiniPlayerState.minimized,
        dragOffset: Offset.zero,
        isDragging: false);
  }

  void close() => value = const MiniPlayerValue(state: MiniPlayerState.hidden);

  void onDragStart() => value = value.copyWith(isDragging: true);

  void onDragUpdate(Offset delta) => value = value.copyWith(
    dragOffset: value.dragOffset + delta,
    isDragging: true,
  );

  void onDragEnd({required Size screenSize, double dismissThreshold = 100.0}) {
    if (value.dragOffset.dy > dismissThreshold) {
      close();
    } else {
      value = value.copyWith(dragOffset: Offset.zero, isDragging: false);
    }
  }

  void updateMediaInfo(
      {required String title, String? subtitle, String? thumbnailUrl}) =>
      value = value.copyWith(
          videoTitle: title,
          videoSubtitle: subtitle,
          thumbnailUrl: thumbnailUrl);
}

class SmartPlayerState {
  const SmartPlayerState({this.isPlaying = false});
  final bool isPlaying;
  SmartPlayerState copyWith({bool? isPlaying}) =>
      SmartPlayerState(isPlaying: isPlaying ?? this.isPlaying);
}

class SmartPlayerController extends ValueNotifier<SmartPlayerState> {
  SmartPlayerController() : super(const SmartPlayerState());
  void play() => value = value.copyWith(isPlaying: true);
  void pause() => value = value.copyWith(isPlaying: false);
}

// ─────────────────────────────────────────────────────────────────────────────
// App entry point
// ─────────────────────────────────────────────────────────────────────────────

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SmartMiniPlayer Demo',
    theme: ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF0000),
        brightness: Brightness.dark,
      ),
    ),
    home: const MiniPlayerDemoScreen(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MiniPlayerDemoScreen
// ─────────────────────────────────────────────────────────────────────────────

class MiniPlayerDemoScreen extends StatefulWidget {
  const MiniPlayerDemoScreen({super.key});

  @override
  State<MiniPlayerDemoScreen> createState() => _MiniPlayerDemoScreenState();
}

class _MiniPlayerDemoScreenState extends State<MiniPlayerDemoScreen>
    with SingleTickerProviderStateMixin {
  final _playerCtrl = SmartPlayerController();
  final _miniCtrl = MiniPlayerController();

  // Full-player appear/disappear animation
  late final AnimationController _fullPlayerAnim;
  late final Animation<double> _fullPlayerFade;
  late final Animation<Offset> _fullPlayerSlide;

  static const _videos = [
    _Video(
      title: 'Flutter 3.0 — What\'s New & Exciting',
      channel: 'Google Developers',
      views: '2.4M',
      duration: '18:32',
      thumb: 'https://picsum.photos/seed/flutter30/480/270',
    ),
    _Video(
      title: 'Building a Custom Video Player from Scratch',
      channel: 'FilledStacks',
      views: '890K',
      duration: '32:10',
      thumb: 'https://picsum.photos/seed/vidplayer/480/270',
    ),
    _Video(
      title: 'Dart Null Safety — Complete Guide 2025',
      channel: 'Reso Coder',
      views: '1.2M',
      duration: '22:45',
      thumb: 'https://picsum.photos/seed/dartnull/480/270',
    ),
    _Video(
      title: 'animations Package Deep Dive',
      channel: 'Flutter Community',
      views: '450K',
      duration: '14:08',
      thumb: 'https://picsum.photos/seed/flutanim/480/270',
    ),
    _Video(
      title: 'State Management Wars 2025',
      channel: 'Robert Brunhage',
      views: '730K',
      duration: '28:59',
      thumb: 'https://picsum.photos/seed/statemgmt/480/270',
    ),
    _Video(
      title: 'Riverpod 3.0 — The Final Boss',
      channel: 'Code with Andrea',
      views: '610K',
      duration: '41:00',
      thumb: 'https://picsum.photos/seed/riverpod3/480/270',
    ),
  ];

  _Video? _activeVideo;

  @override
  void initState() {
    super.initState();

    _fullPlayerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _fullPlayerFade = CurvedAnimation(
      parent: _fullPlayerAnim,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _fullPlayerSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fullPlayerAnim, curve: Curves.easeOutCubic),
    );

    _miniCtrl.addListener(_onMiniChanged);
  }

  @override
  void dispose() {
    _playerCtrl.dispose();
    _miniCtrl.dispose();
    _fullPlayerAnim.dispose();
    super.dispose();
  }

  void _onMiniChanged() {
    final state = _miniCtrl.value.state;
    if (state == MiniPlayerState.expanded) {
      _fullPlayerAnim.forward();
    } else {
      _fullPlayerAnim.reverse();
    }
    setState(() {});
  }

  // Play new video
  void _playVideo(_Video v) {
    setState(() => _activeVideo = v);
    _miniCtrl.openMiniPlayer(
      title: v.title,
      subtitle: v.channel,
      thumbnailUrl: v.thumb,
    );
    _miniCtrl.expand();
    _playerCtrl.play();
  }

  // Minimize from full player
  void _minimize() => _miniCtrl.minimize();

  // Expand from mini player
  void _expandFromMini() => _miniCtrl.expand();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // ── 1. Main content ──────────────────────────────
          Column(
            children: [
              _TopBar(
                onSearch: () {},
                onNotif: () {},
              ),
              Expanded(
                child: _VideoFeed(
                  videos: _videos,
                  activeVideo: _activeVideo,
                  onVideoTap: _playVideo,
                ),
              ),
            ],
          ),

          // ── 2. Full-screen player (expanded state) ───────
          if (_activeVideo != null)
            FadeTransition(
              opacity: _fullPlayerFade,
              child: SlideTransition(
                position: _fullPlayerSlide,
                child: IgnorePointer(
                  ignoring: !_miniCtrl.value.isExpanded,
                  child: _FullPlayer(
                    video: _activeVideo!,
                    playerCtrl: _playerCtrl,
                    onMinimize: _minimize,
                  ),
                ),
              ),
            ),

          // ── 3. SmartMiniPlayer ────────────────────────────
          if (_activeVideo != null)
            _FloatingMiniPlayer(
              miniCtrl: _miniCtrl,
              playerCtrl: _playerCtrl,
              onExpand: _expandFromMini,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TopBar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSearch, required this.onNotif});
  final VoidCallback onSearch;
  final VoidCallback onNotif;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          border: Border(bottom: BorderSide(color: Color(0xFF1F1F1F))),
        ),
        child: Row(
          children: [
            const Icon(Icons.smart_display,
                color: Color(0xFFFF0000), size: 28),
            const SizedBox(width: 6),
            const Text(
              'SmartPlayerKit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: onSearch,
                icon: const Icon(Icons.search, color: Colors.white70)),
            IconButton(
                onPressed: onNotif,
                icon: const Icon(Icons.notifications_none,
                    color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _VideoFeed
// ─────────────────────────────────────────────────────────────────────────────

class _VideoFeed extends StatelessWidget {
  const _VideoFeed({
    required this.videos,
    required this.activeVideo,
    required this.onVideoTap,
  });

  final List<_Video> videos;
  final _Video? activeVideo;
  final void Function(_Video) onVideoTap;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.only(bottom: 130),
    itemCount: videos.length,
    itemBuilder: (_, i) => _VideoCard(
      video: videos[i],
      isActive: activeVideo?.title == videos[i].title,
      onTap: () => onVideoTap(videos[i]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _VideoCard
// ─────────────────────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.video,
    required this.isActive,
    required this.onTap,
  });

  final _Video video;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isActive ? const Color(0xFF1C1C1C) : Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    video.thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1C1C1C),
                      child: const Center(
                        child: Icon(Icons.videocam,
                            color: Colors.white24, size: 40),
                      ),
                    ),
                  ),
                ),
                // Duration
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                // "Now Playing" overlay
                if (isActive)
                  Positioned.fill(
                    child: Container(
                      color: Colors.red..withValues(alpha: 0.12),
                      child: const Center(
                        child: Icon(Icons.play_circle_filled,
                            color: Colors.white60, size: 52),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Info ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF272727),
                    child: Text(
                      video.channel[0],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${video.channel} • ${video.views} views',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert,
                      color: Colors.white38, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FullPlayer — expanded full screen player
// ─────────────────────────────────────────────────────────────────────────────

class _FullPlayer extends StatelessWidget {
  const _FullPlayer({
    required this.video,
    required this.playerCtrl,
    required this.onMinimize,
  });

  final _Video video;
  final SmartPlayerController playerCtrl;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0F0F),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Video area ────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Image.network(
                    video.thumb,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.videocam,
                            color: Colors.white24, size: 64),
                      ),
                    ),
                  ),
                  _PlayerOverlay(
                    playerCtrl: playerCtrl,
                    onMinimize: onMinimize,
                  ),
                ],
              ),
            ),

            // ── Video meta ────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${video.views} views • ${video.channel}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF2A2A2A)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ActionChip(
                            icon: Icons.thumb_up_outlined, label: '12K'),
                        _ActionChip(
                            icon: Icons.thumb_down_outlined,
                            label: 'Dislike'),
                        _ActionChip(icon: Icons.reply, label: 'Share'),
                        _ActionChip(
                            icon: Icons.playlist_add, label: 'Save'),
                        _ActionChip(
                            icon: Icons.download_outlined,
                            label: 'Download'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFF2A2A2A)),
                    const SizedBox(height: 12),
                    const Text(
                      'Up Next',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerOverlay extends StatelessWidget {
  const _PlayerOverlay(
      {required this.playerCtrl, required this.onMinimize});

  final SmartPlayerController playerCtrl;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent, Colors.black54],
          stops: [0, 0.45, 1],
        ),
      ),
      child: Column(
        children: [
          // ── Top bar ──────────────────────────────────────
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 28),
                  onPressed: onMinimize,
                  tooltip: 'Minimize',
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.cast,
                      color: Colors.white, size: 22),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.white, size: 22),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // ── Center play/pause ─────────────────────────
          const Spacer(),
          ValueListenableBuilder<SmartPlayerState>(
            valueListenable: playerCtrl,
            builder: (_, state, __) => GestureDetector(
              onTap: () =>
              state.isPlaying ? playerCtrl.pause() : playerCtrl.play(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  state.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  key: ValueKey(state.isPlaying),
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ),
          const Spacer(),

          // ── Progress bar (fake) ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: const Color(0xFFFF0000),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFFFF0000),
                  ),
                  child: Slider(value: 0.35, onChanged: (_) {}),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('6:18',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    Text('18:32',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF272727),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _FloatingMiniPlayer — SmartMiniPlayer ko wrap karta hai
// (asli package mein SmartMiniPlayer directly use karo)
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingMiniPlayer extends StatefulWidget {
  const _FloatingMiniPlayer({
    required this.miniCtrl,
    required this.playerCtrl,
    required this.onExpand,
  });

  final MiniPlayerController miniCtrl;
  final SmartPlayerController playerCtrl;
  final VoidCallback onExpand;

  @override
  State<_FloatingMiniPlayer> createState() => _FloatingMiniPlayerState();
}

class _FloatingMiniPlayerState extends State<_FloatingMiniPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  Offset _base = Offset.zero;
  bool _baseSet = false;

  static const double _w = 230;
  static const double _h = 135;
  static const double _margin = 14;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 320));
    _scale = CurvedAnimation(
        parent: _anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic);
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _anim, curve: const Interval(0, 0.5)));
    widget.miniCtrl.addListener(_onCtrl);
    _syncAnim(widget.miniCtrl.value.state);
  }

  @override
  void dispose() {
    widget.miniCtrl.removeListener(_onCtrl);
    _anim.dispose();
    super.dispose();
  }

  void _onCtrl() {
    _syncAnim(widget.miniCtrl.value.state);
    if (mounted) setState(() {});
  }

  void _syncAnim(MiniPlayerState s) {
    if (s == MiniPlayerState.minimized) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  void _initBase(Size size) {
    if (_baseSet) return;
    _baseSet = true;
    _base = Offset(
      size.width - _w - _margin,
      size.height - _h - _margin - 80,
    );
  }

  Offset _clampedPos(Offset base, Offset drag, Size size) {
    final raw = base + drag;
    return Offset(
      raw.dx.clamp(_margin, size.width - _w - _margin),
      raw.dy.clamp(_margin, size.height - _h - _margin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _initBase(size);

    return ValueListenableBuilder<MiniPlayerValue>(
      valueListenable: widget.miniCtrl,
      builder: (_, val, __) {
        if (val.isHidden && _anim.isDismissed) {
          return const SizedBox.shrink();
        }

        final pos = _clampedPos(_base, val.dragOffset, size);

        return AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            final sc = _scale.value;
            final op = _opacity.value.clamp(0.0, 1.0);
            if (sc < 0.01) return const SizedBox.shrink();

            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: Opacity(
                opacity: op,
                child: Transform.scale(
                  scale: sc,
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      widget.miniCtrl.expand();
                      widget.onExpand();
                    },
                    onPanStart: (_) => widget.miniCtrl.onDragStart(),
                    onPanUpdate: (d) =>
                        widget.miniCtrl.onDragUpdate(d.delta),
                    onPanEnd: (_) =>
                        widget.miniCtrl.onDragEnd(screenSize: size),
                    child: _MiniCard(
                      val: val,
                      playerCtrl: widget.playerCtrl,
                      onClose: widget.miniCtrl.close,
                      onPlayPause: () {
                        if (widget.playerCtrl.value.isPlaying) {
                          widget.playerCtrl.pause();
                        } else {
                          widget.playerCtrl.play();
                        }
                      },
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
// _MiniCard — mini player card UI
// ─────────────────────────────────────────────────────────────────────────────

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.val,
    required this.playerCtrl,
    required this.onClose,
    required this.onPlayPause,
  });

  final MiniPlayerValue val;
  final SmartPlayerController playerCtrl;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;

  static const double _w = 230;
  static const double _h = 135;
  static const double _thumbW = 94;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 14,
      shadowColor: Colors.black,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: _w,
        height: _h,
        color: const Color(0xFF1A1A1A),
        child: Row(
          children: [
            // ── Thumbnail ──────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: SizedBox(
                width: _thumbW,
                height: _h,
                child: val.thumbnailUrl != null
                    ? Image.network(
                  val.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _PlaceholderThumb(w: _thumbW, h: _h),
                )
                    : _PlaceholderThumb(w: _thumbW, h: _h),
              ),
            ),

            // ── Info + controls ────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row + close
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            val.videoTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onClose,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.close,
                                size: 13, color: Colors.white54),
                          ),
                        ),
                      ],
                    ),

                    if (val.videoSubtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        val.videoSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ],

                    const Spacer(),

                    // Play / Pause
                    ValueListenableBuilder<SmartPlayerState>(
                      valueListenable: playerCtrl,
                      builder: (_, state, __) {
                        final playing = state.isPlaying;
                        return GestureDetector(
                          onTap: onPlayPause,
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: playing
                                  ? Colors.white12
                                  : const Color(0xFFFF0000),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  playing ? 'Pause' : 'Play',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  const _PlaceholderThumb({required this.w, required this.h});
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) => Container(
    width: w,
    height: h,
    color: Colors.black,
    child: const Icon(Icons.movie, color: Colors.white24, size: 28),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _Video data model
// ─────────────────────────────────────────────────────────────────────────────

class _Video {
  const _Video({
    required this.title,
    required this.channel,
    required this.views,
    required this.duration,
    required this.thumb,
  });

  final String title;
  final String channel;
  final String views;
  final String duration;
  final String thumb;
}