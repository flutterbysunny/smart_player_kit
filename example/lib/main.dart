import 'package:flutter/material.dart';
import 'package:smart_player_kit/smart_player_kit.dart';

void main() {
  runApp(const SmartPlayerExampleApp());
}

class SmartPlayerExampleApp extends StatelessWidget {
  const SmartPlayerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPlayerKit Demo',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartPlayerKit Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DemoTile(
            title: '🎬 Basic Video Player',
            subtitle: 'One-liner network video',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BasicPlayerScreen()),
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

// ─── URLs — Flutter official CDN, iOS/Android dono pe tested ──────────────────
// Source: https://flutter.github.io/assets-for-api-docs/assets/videos/
// Ye Flutter team khud use karti hai — guaranteed working
class _Urls {
  static const butterfly =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
  static const bee =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  static const hls =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8';
}

// ─── Basic Player ─────────────────────────────────────────────────────────────

class BasicPlayerScreen extends StatelessWidget {
  const BasicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Player')),
      body: Column(
        children: [
          // ✅ One-liner!
          SmartPlayer.network(_Urls.butterfly, title: 'Butterfly'),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'SmartPlayer.network(url) — bas itna likho, sab kuch ready!',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HLS Player ───────────────────────────────────────────────────────────────

class HlsPlayerScreen extends StatefulWidget {
  const HlsPlayerScreen({super.key});

  @override
  State<HlsPlayerScreen> createState() => _HlsPlayerScreenState();
}

class _HlsPlayerScreenState extends State<HlsPlayerScreen> {
  late SmartPlayerController _controller;

  // Bee video ke saath match karta VTT (4 second video)
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
    _controller = SmartPlayerController(
      config: SmartPlayerConfig.hls(_Urls.hls, autoPlay: true),
    );
    _controller.initialize().then((_) {
      // ✅ Initialize ke baad directly parse karo
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
            controller: _controller,  // ✅ same controller pass karo
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

// ─── Auto Resume ──────────────────────────────────────────────────────────────

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

// ─── Reels ────────────────────────────────────────────────────────────────────

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

// ─── Audio ────────────────────────────────────────────────────────────────────

class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  // MP3 — Internet Archive se, free public domain audio
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

// ─── Themed Player ────────────────────────────────────────────────────────────

class ThemedPlayerScreen extends StatelessWidget {
  const ThemedPlayerScreen({super.key});

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
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

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