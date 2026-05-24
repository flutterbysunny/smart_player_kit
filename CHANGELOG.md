# Changelog

## 1.0.0

### 🎉 Initial stable release

#### Core Player
- `SmartPlayerController` — ValueNotifier based, full playback control
- `SmartPlayerConfig` — network, HLS, file, asset sources
- `SmartPlayer` widget — YouTube / Netflix / Minimal control styles
- `SmartPlayerTheme` — fully customizable colors, fonts, icons

#### Streaming
- HLS `.m3u8` stream support
- Auto quality detection
- Buffering indicator

#### Subtitles
- SRT and WebVTT parser
- `SubtitleController` — real-time position sync
- `SubtitleOverlay` widget
- `SubtitleSelector` — runtime track switching

#### Mini Player
- `SmartMiniPlayer` — YouTube-style draggable floating mini player
- `MiniPlayerController` — expanded / minimized / hidden state
- Live video in mini player (shared `VideoPlayerController`)
- Drag anywhere, dismiss on swipe down
- Play/Pause + Close controls

#### Reels / Short Video
- `SmartReelsPlayer` — TikTok/Instagram style vertical feed
- Auto play on scroll, pause on scroll away
- Like, comment, share callbacks

#### Audio Player
- `SmartAudioPlayer` — Podcast / Music player
- Full, compact, and minimal styles
- Lock screen + notification controls

#### Background Playback
- `BackgroundService` — continues playback when app is minimized
- `NotificationControls` — play/pause from notification

#### Resume
- `ResumeManager` — SharedPreferences based position save/restore
- Per-video `resumeKey` support

#### Analytics
- `PlayerAnalytics` — watch time, pause count, completion %
- Callbacks for play, pause, seek, complete events

#### Gestures
- Double-tap seek (left/right)
- Swipe up/down for volume and brightness