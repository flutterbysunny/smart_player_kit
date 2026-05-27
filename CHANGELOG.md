# Changelog

## 1.0.1

### 🐛 Bug Fixes & Improvements

- Fixed `withOpacity` deprecated calls — replaced with `withValues(alpha:)`
- Fixed `onPopInvoked` deprecated — replaced with `onPopInvokedWithResult`
- Fixed `AndroidNotificationAction` constructor for flutter_local_notifications v21
- Fixed `initialize()` named parameter `settings:` for notifications v21
- Fixed unnecessary imports across controls and subtitle files
- Fixed curly braces in subtitle parser if-statement
- Fixed `library` name declaration warning
- Updated all dependencies to latest stable versions:
    - `audio_session` → `^0.2.3`
    - `connectivity_plus` → `^7.1.1`
    - `flutter_local_notifications` → `^21.0.0`
    - `just_audio` → `^0.10.5`
    - `screen_brightness` → `^2.1.8`
    - `volume_controller` → `^3.5.0`
- Added `http` dependency for subtitle fetching
- Added `video_player` to example app dependencies

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