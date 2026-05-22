/// SmartPlayerKit — Complete Flutter Media Player Framework
///
/// OTT, Course, Podcast, Reels, Music — sab ek package mein.
///
/// ## Quick Start
///
/// ```dart
/// // Simplest usage — one line!
/// SmartPlayer.network('https://example.com/video.mp4')
///
/// // With resume + subtitles
/// SmartPlayer.config(
///   SmartPlayerConfig.hls(
///     'https://example.com/stream.m3u8',
///     resumePlayback: true,
///     subtitles: [
///       SubtitleTrack(label: 'English', languageCode: 'en', url: 'https://...'),
///       SubtitleTrack(label: 'Hindi', languageCode: 'hi', url: 'https://...'),
///     ],
///   ),
/// )
///
/// // Reels player
/// SmartReelsPlayer(
///   videos: [
///     ReelItem(videoUrl: 'https://...'),
///     ReelItem(videoUrl: 'https://...'),
///   ],
/// )
///
/// // Audio/Podcast player
/// SmartAudioPlayer(
///   audioUrl: 'https://example.com/episode.mp3',
///   title: 'Episode 42',
///   artist: 'My Podcast',
/// )
/// ```
library smart_player_kit;

// ─── Core ─────────────────────────────────────────────────────────────────────
export 'src/controller/smart_player_controller.dart';
export 'src/controller/smart_player_config.dart';
export 'src/controls/smart_player_state.dart';
export 'src/theme/smart_player_theme.dart';

// ─── Widgets ──────────────────────────────────────────────────────────────────
export 'src/player/smart_player.dart';
export 'src/player/smart_reels_player.dart';
export 'src/player/smart_audio_player.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
export 'src/subtitle/subtitle_track.dart';
export 'src/audio_tracks/audio_track.dart';
export 'src/drm/drm_config.dart';

// ─── Resume ───────────────────────────────────────────────────────────────────
export 'src/resume/resume_manager.dart';

// ─── Analytics ────────────────────────────────────────────────────────────────
export 'src/analytics/player_analytics.dart';

// ─── Gestures ─────────────────────────────────────────────────────────────────
export 'src/gestures/gesture_detector.dart';

// ─── Controls ─────────────────────────────────────────────────────────────────
export 'src/controls/progress_bar.dart';
export 'src/controls/youtube_controls.dart';
export 'src/controls/netflix_controls.dart';
export 'src/controls/minimal_controls.dart';

// ─── Subtitle ─────────────────────────────────────────────────────────────────
export 'src/subtitle/subtitle_controller.dart';
export 'src/subtitle/subtitle_overlay.dart';
export 'src/subtitle/subtitle_selector.dart';