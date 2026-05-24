# smart_player_kit

<p align="center">
  <img src="https://raw.githubusercontent.com/flutterbysunny/smart_player_kit/main/assets/banner.png">
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/flutterbysunny/smart_player_kit/main/assets/logo.png" width="300">
</p>

<h1 align="center">smart_player_kit</h1>

<p align="center">
  Advanced Flutter media player kit with modern controls.
</p>

<p align="center">
  🔥 HLS Streaming • 🎬 Reels Support • 📺 Subtitles • ⚡ Background Playback
</p>

<p align="center">
  Advanced Flutter media player kit with modern controls, subtitles, cache, reels support and background playback.
</p>

---

## ✨ Features

- 🎬 **Video Player** — YouTube / Netflix / Minimal styles
- 📺 **HLS / M3U8 Streaming**
- 🪟 **Mini Player** — YouTube-style draggable floating player
- 📝 **Subtitles** — SRT and WebVTT with real-time sync
- 🎵 **Audio Player** — Podcast / Music (full, compact, minimal)
- 📱 **Reels Player** — TikTok/Instagram style vertical feed
- ⏯ **Background Playback** — plays when app is minimized
- 🔄 **Auto Resume** — saves and restores playback position
- 📊 **Analytics** — watch time, pause count, completion %
- 👆 **Gestures** — double-tap seek, swipe volume/brightness
- 🔆 **Fullscreen Support**
- 🎨 **Custom Themes & Controls**

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  smart_player_kit: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

```dart
import 'package:smart_player_kit/smart_player_kit.dart';

SmartPlayer.network(
  'https://example.com/video.mp4',
  title: 'My Video',
);
```

---

## 📘 Usage

---

### Basic Video Player

```dart
SmartPlayer.network(
  'https://example.com/video.mp4',
  title: 'My Video',
);
```

---

### HLS Stream

```dart
SmartPlayer.config(
  SmartPlayerConfig.hls(
    'https://example.com/stream.m3u8',
    autoPlay: true,
  ),
  title: 'Live Stream',
);
```

---

### Netflix Style Player

```dart
SmartPlayer.config(
  SmartPlayerConfig.network(
    'https://example.com/video.mp4',
    controlsStyle: SmartPlayerControlsStyle.netflix,
    theme: SmartPlayerTheme.netflix(),
  ),
  title: 'Netflix Style',
);
```

---

### Auto Resume Playback

```dart
SmartPlayer.config(
  SmartPlayerConfig.network(
    'https://example.com/video.mp4',
    resumePlayback: true,
    resumeKey: 'my_video_1',
  ),
  title: 'Resume Demo',
);
```

---

### Mini Player

```dart
final playerCtrl = SmartPlayerController(
  config: SmartPlayerConfig.network(
    url,
    autoPlay: true,
  ),
);

final miniCtrl = MiniPlayerController();

miniCtrl.openMiniPlayer(
  title: 'My Video',
  subtitle: 'Channel Name',
);

miniCtrl.minimize();

SmartMiniPlayer(
  miniController: miniCtrl,
  playerController: playerCtrl,
  videoWidget: VideoPlayer(playerCtrl.videoController!),
  onExpand: () {
    // show full player
  },
);
```

---

### Reels Player

```dart
SmartReelsPlayer(
  videos: [
    ReelItem(
      videoUrl: 'https://example.com/reel1.mp4',
      authorName: 'flutter_dev',
      description: 'My first reel!',
      likeCount: 1200,
      commentCount: 34,
    ),
  ],
  onLike: (index, item) {},
  onComment: (index, item) {},
  onShare: (index, item) {},
);
```

---

### Audio Player

```dart
SmartAudioPlayer(
  audioUrl: 'https://example.com/audio.mp3',
  title: 'My Podcast',
  artist: 'Sunny Singh',
  style: AudioPlayerStyle.full,
);
```

---

### Subtitles (SRT / WebVTT)

```dart
final controller = SmartPlayerController(
  config: SmartPlayerConfig.network(url),
);

await controller.initialize();

controller.subtitleController.parseAndLoad(
  vttString,
  SubtitleFormat.webvtt,
);
```

---

## 🎨 Supported Player Styles

| Style | Description |
|-------|-------------|
| Minimal | Lightweight clean controls |
| YouTube | Familiar YouTube-like controls |
| Netflix | OTT / Netflix style controls |

---

## 📱 Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅ |
| iOS      | ✅ |

---

## ⚙️ Requirements

- Flutter `>=3.10.0`
- Dart `>=3.0.0`

---

## 🔥 Upcoming Features

- Chromecast Support
- Download & Offline Playback
- DRM Support
- Playlist Queue
- PiP (Picture in Picture)
- Web Support

---

## 🤝 Contributing

Contributions are welcome!

If you’d like to improve `smart_player_kit`, feel free to:

1. Fork the repo
2. Create a new branch
3. Make your changes
4. Submit a Pull Request

---

## 🐛 Issues & Feature Requests

Please open an issue on GitHub if you find bugs or want to request features.

---

## 📄 License

MIT License — Copyright (c) 2026 Sunny Singh

See [LICENSE](LICENSE) for details.