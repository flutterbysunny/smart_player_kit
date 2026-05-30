import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:smart_player_kit/smart_player_kit.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SmartPlayerExampleApp()
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
// App root
// ─────────────────────────────────────────────────────────────────────────────

class SmartPlayerExampleApp extends StatefulWidget {
  const SmartPlayerExampleApp({super.key});

  @override
  State<SmartPlayerExampleApp> createState() => _SmartPlayerExampleAppState();
}

class _SmartPlayerExampleAppState extends State<SmartPlayerExampleApp> {
  final _playerCtrl = SmartPlayerController(
    config: SmartPlayerConfig.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      autoPlay: true,
    ),
  );

  final _miniCtrl = MiniPlayerController();
  final _navKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _playerCtrl.dispose();
    _miniCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPlayerKit Demo',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      navigatorKey: _navKey,
      builder: (context, child) {
        return Stack(
          children: [
            child!,

            // ✅ Live video mini player mein dikhega — same VideoPlayerController
            ValueListenableBuilder<SmartPlayerValue>(
              valueListenable: _playerCtrl,
              builder: (context, val, _) {
                return SmartMiniPlayer(

                  miniController: _miniCtrl,
                  playerController: _playerCtrl,
                  onExpand: _onMiniPlayerExpand,
                  videoWidget: _playerCtrl.videoController != null
                      ? VideoPlayer(_playerCtrl.videoController!)
                      : null,
                );
              },
            ),
          ],
        );
      },
      home: HomeScreen(
        miniCtrl: _miniCtrl,
        playerCtrl: _playerCtrl,
      ),
    );
  }

  void _onMiniPlayerExpand() {
    _miniCtrl.expand();
    _navKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => BasicPlayerScreen(
          miniCtrl: _miniCtrl,
          playerCtrl: _playerCtrl,
          fromMiniPlayer: true,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// URLs
// ─────────────────────────────────────────────────────────────────────────────

class _Urls {
  static const butterfly =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
  static const bee =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  static const hls =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8';
}

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.miniCtrl,
    required this.playerCtrl,
  });

  final MiniPlayerController miniCtrl;
  final SmartPlayerController playerCtrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartPlayerKit Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DemoTile(
            title: '🎬 Basic Video Player',
            subtitle: 'One-liner network video + Mini Player',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BasicPlayerScreen(
                  miniCtrl: miniCtrl,
                  playerCtrl: playerCtrl,
                ),
              ),
            ),
          ),
          _DemoTile(
            title: '📺 HLS Stream',
            subtitle: 'HLS .m3u8 stream playback',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HlsPlayerScreen()),
            ),
          ),
          _DemoTile(
            title: '🔄 Auto Resume',
            subtitle: 'Netflix-style — last position se continue',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResumePlayerScreen()),
            ),
          ),
          _DemoTile(
            title: '📱 Reels Player',
            subtitle: 'TikTok/Instagram style vertical feed',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReelsScreen()),
            ),
          ),
          _DemoTile(
            title: '🎵 Audio / Podcast',
            subtitle: 'Podcast + music player',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AudioScreen()),
            ),
          ),
          _DemoTile(
            title: '🎨 Netflix Theme',
            subtitle: 'Custom red Netflix-style controls',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemedPlayerScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BasicPlayerScreen
// ─────────────────────────────────────────────────────────────────────────────

class BasicPlayerScreen extends StatefulWidget {
  const BasicPlayerScreen({
    super.key,
    required this.miniCtrl,
    required this.playerCtrl,
    this.fromMiniPlayer = false,
  });

  final MiniPlayerController miniCtrl;
  final SmartPlayerController playerCtrl;
  final bool fromMiniPlayer;

  // ✅ pipController widget mein nahi — State mein hoga
  @override
  State<BasicPlayerScreen> createState() => _BasicPlayerScreenState();
}

class _BasicPlayerScreenState extends State<BasicPlayerScreen> {
  // ✅ late final — initState mein initialize hoga
  late final PipController _pipController;
  bool _isPipMode = false; // ✅ PiP state track karo

  @override
  void initState() {
    super.initState();

    // ✅ underscore se access karo
    _pipController = PipController();
    _pipController.initialize();

    // ✅ PiP mode change listener
    _pipController.channel.setMethodCallHandler((call) async {
      if (call.method == 'pipModeChanged') {
        setState(() {
          _isPipMode = call.arguments as bool;
        });
      }
    });


    if (!widget.fromMiniPlayer) {
      widget.playerCtrl.loadNewVideo(
        SmartPlayerConfig.network(_Urls.butterfly, autoPlay: true),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.miniCtrl.openMiniPlayer(
          title: 'Butterfly',
          subtitle: 'Flutter Official Demo Video',
        );
        widget.miniCtrl.expand();
      });
    }
  }

  @override
  void dispose() {
    _pipController.dispose();
    super.dispose();
  }

  void _minimize() {
    widget.miniCtrl.minimize();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ PiP mode mein controls hide karo
            if (!_isPipMode)
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: _minimize,
                    ),
                    const Spacer(),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(
                        Icons.picture_in_picture_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _pipController.enterPip(),
                    ),
                  ],
                ),
              ),

            // ✅ PiP mein video full screen le lo
            _isPipMode
                ? Expanded(
              child: SmartPlayer.config(
                SmartPlayerConfig.network(_Urls.butterfly, autoPlay: true),
                title: 'Butterfly',
                controller: widget.playerCtrl,
              ),
            )
                : SmartPlayer.config(
              SmartPlayerConfig.network(_Urls.butterfly, autoPlay: true),
              title: 'Butterfly',
              controller: widget.playerCtrl,
            ),

            // ✅ PiP mein info panel hide karo
            if (!_isPipMode)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Butterfly',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Flutter Official Demo Video',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
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
// HlsPlayerScreen
// ─────────────────────────────────────────────────────────────────────────────

class HlsPlayerScreen extends StatefulWidget {
  const HlsPlayerScreen({super.key});

  @override
  State<HlsPlayerScreen> createState() => _HlsPlayerScreenState();
}

class _HlsPlayerScreenState extends State<HlsPlayerScreen> {
  late final SmartPlayerController _controller = SmartPlayerController(
    config: SmartPlayerConfig.hls(_Urls.hls, autoPlay: true),
  );

  static const _testVtt = '''
WEBVTT

00:00:00.000 --> 00:00:01.500
Ye ek bee hai 🐝

00:00:01.500 --> 00:00:03.000
SmartPlayerKit — subtitle test

00:00:03.000 --> 00:00:04.500
Subtitle working hai! ✅
''';

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) {
      _controller.subtitleController.parseAndLoad(
        _testVtt,
        SubtitleFormat.webvtt,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HLS + Subtitle')),
      body: Column(
        children: [
          SmartPlayer.config(
            SmartPlayerConfig.hls(_Urls.hls),
            title: 'Subtitle Demo',
            controller: _controller,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '💡 Video ke upar subtitle dikh rahi hai.\n'
                  'Video start hone par 0–4 sec mein text show hoga.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ResumePlayerScreen
// ─────────────────────────────────────────────────────────────────────────────

class ResumePlayerScreen extends StatelessWidget {
  const ResumePlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Resume')),
      body: Column(
        children: [
          SmartPlayer.config(
            SmartPlayerConfig.network(
              _Urls.butterfly,
              resumePlayback: true,
              resumeKey: 'demo_butterfly',
            ),
            title: 'Butterfly — Resume Demo',
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Kuch der chalao → back jao → wapas aao.\nWahi se shuru hoga jahan chhodha tha!',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ReelsScreen
// ─────────────────────────────────────────────────────────────────────────────

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  static final _reels = [
    const ReelItem(
      videoUrl: _Urls.butterfly,
      authorName: 'flutter_dev',
      description: 'Flutter animations are amazing! 🦋 #flutter #coding',
      likeCount: 12400,
      commentCount: 234,
    ),
    const ReelItem(
      videoUrl: _Urls.bee,
      authorName: 'sunnydev',
      description: 'SmartPlayerKit — reels mode demo 🎬 #smartplayer',
      likeCount: 8900,
      commentCount: 156,
      isLiked: true,
    ),
    const ReelItem(
      videoUrl: _Urls.butterfly,
      authorName: 'media_magic',
      description: 'Vertical scroll player — TikTok style! ⚡',
      likeCount: 45200,
      commentCount: 890,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartReelsPlayer(
        videos: _reels,
        onLike: (index, item) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❤️ Liked reel ${index + 1}!'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onComment: (index, item) {},
        onShare: (index, item) {},
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AudioScreen
// ─────────────────────────────────────────────────────────────────────────────

class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  static const _audioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podcast Player')),
      body: SmartAudioPlayer(
        audioUrl: _audioUrl,
        title: 'Flutter Development Tips',
        artist: 'SmartCast Podcast',
        style: AudioPlayerStyle.full,
        theme: SmartPlayerTheme(primaryColor: Colors.deepPurple),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemedPlayerScreen
// ─────────────────────────────────────────────────────────────────────────────

class ThemedPlayerScreen extends StatefulWidget {
  const ThemedPlayerScreen({super.key});

  @override
  State<ThemedPlayerScreen> createState() => _ThemedPlayerScreenState();
}

class _ThemedPlayerScreenState extends State<ThemedPlayerScreen> {
  late final SmartPlayerController _controller = SmartPlayerController(
    config: SmartPlayerConfig.network(
      _Urls.bee,
      controlsStyle: SmartPlayerControlsStyle.netflix,
      theme: SmartPlayerTheme.netflix(),
      autoPlay: true,
    ),
  );

  static const _testVtt = '''
WEBVTT

00:00:00.000 --> 00:00:01.500
Netflix Style Player 🎬

00:00:01.500 --> 00:00:03.000
SmartPlayerKit — Phase 2

00:00:03.000 --> 00:00:04.500
Subtitle icon press karo ⬆️
''';

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) {
      _controller.subtitleController.parseAndLoad(
        _testVtt,
        SubtitleFormat.webvtt,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Netflix Theme'),
      ),
      body: SmartPlayer.config(
        SmartPlayerConfig.network(
          _Urls.bee,
          controlsStyle: SmartPlayerControlsStyle.netflix,
          theme: SmartPlayerTheme.netflix(),
        ),
        title: 'Netflix Style Player',
        controller: _controller,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DemoTile
// ─────────────────────────────────────────────────────────────────────────────

class _DemoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DemoTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}