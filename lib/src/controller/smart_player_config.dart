import 'package:flutter/material.dart';
import '../subtitle/subtitle_track.dart';
import '../audio_tracks/audio_track.dart';
import '../drm/drm_config.dart';
import '../theme/smart_player_theme.dart';

/// Video source ka type
enum SmartPlayerSourceType {
  /// HTTP/HTTPS network URL
  network,

  /// HLS / M3U8 stream
  hls,

  /// Device storage ka file
  file,

  /// App ke andar ka asset
  asset,
}

/// Controls ka style
enum SmartPlayerControlsStyle {
  /// Netflix jaisi dark controls
  netflix,

  /// YouTube jaisi controls
  youtube,

  /// Simple minimal controls
  minimal,

  /// Reels/TikTok style (vertical)
  reels,

  /// Koi controls nahi — khud banao
  none,
}

/// SmartPlayer ka complete configuration
class SmartPlayerConfig {
  // ─── Source ──────────────────────────────────────────────────────────────

  /// Video URL ya file path
  final String url;

  /// Source type (auto-detect bhi hota hai)
  final SmartPlayerSourceType sourceType;

  // ─── Playback ─────────────────────────────────────────────────────────────

  /// Auto play karo player load hote hi
  final bool autoPlay;

  /// Loop karo video khatam hone par
  final bool loop;

  /// Starting volume (0.0 to 1.0)
  final double volume;

  /// Starting playback speed
  final double playbackSpeed;

  /// Jahan se start karo (resume ke liye)
  final Duration startPosition;

  // ─── Resume ───────────────────────────────────────────────────────────────

  /// Netflix-style auto resume — last position se shuru karo
  final bool resumePlayback;

  /// Resume key — unique ID for this video (null = url use hoga)
  final String? resumeKey;

  // ─── Controls ─────────────────────────────────────────────────────────────

  /// Controls ka style
  final SmartPlayerControlsStyle controlsStyle;

  /// Controls kitni der baad chhup jayein (seconds)
  final Duration controlsHideDelay;

  /// Fullscreen allow karo
  final bool allowFullscreen;

  /// Playback speed change allow karo
  final bool allowSpeedControl;

  // ─── Gestures ─────────────────────────────────────────────────────────────

  /// Double-tap seek allow karo
  final bool enableDoubleTapSeek;

  /// Double-tap mein kitne seconds seek ho
  final int doubleTapSeekSeconds;

  /// Swipe se brightness control
  final bool enableBrightnessGesture;

  /// Swipe se volume control
  final bool enableVolumeGesture;

  /// Pinch zoom allow karo
  final bool enablePinchZoom;

  // ─── Subtitles ────────────────────────────────────────────────────────────

  /// Subtitle tracks list
  final List<SubtitleTrack> subtitles;

  /// Default subtitle index
  final int defaultSubtitleIndex;

  // ─── Audio Tracks ─────────────────────────────────────────────────────────

  /// Audio tracks list (Hindi, English, etc.)
  final List<AudioTrack> audioTracks;

  /// Default audio track index
  final int defaultAudioTrackIndex;

  // ─── Cache ────────────────────────────────────────────────────────────────

  /// Auto cache karo
  final bool enableCache;

  /// Agle video ka URL — preload ke liye
  final String? nextVideoUrl;

  // ─── Background ───────────────────────────────────────────────────────────

  /// App minimize hone par bhi play karo
  final bool enableBackgroundPlayback;

  // ─── Download ─────────────────────────────────────────────────────────────

  /// Download button show karo
  final bool showDownloadButton;

  // ─── Thumbnail ────────────────────────────────────────────────────────────

  /// Video thumbnail URL (loading ke time dikhao)
  final String? thumbnailUrl;

  /// Thumbnail widget (custom)
  final Widget? placeholder;

  // ─── DRM ──────────────────────────────────────────────────────────────────

  /// DRM configuration (Widevine / FairPlay)
  final DrmConfig? drmConfig;

  // ─── Theme ────────────────────────────────────────────────────────────────

  /// Player ka custom theme
  final SmartPlayerTheme? theme;

  // ─── Callbacks ────────────────────────────────────────────────────────────

  /// Video ready hone par
  final VoidCallback? onReady;

  /// Play start hone par
  final VoidCallback? onPlay;

  /// Pause hone par
  final VoidCallback? onPause;

  /// Video complete hone par
  final VoidCallback? onComplete;

  /// Error aane par
  final void Function(String error)? onError;

  /// Position change hone par (seek bar ke liye)
  final void Function(Duration position)? onPositionChanged;

  const SmartPlayerConfig({
    required this.url,
    this.sourceType = SmartPlayerSourceType.network,
    // Playback
    this.autoPlay = true,
    this.loop = false,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.startPosition = Duration.zero,
    // Resume
    this.resumePlayback = false,
    this.resumeKey,
    // Controls
    this.controlsStyle = SmartPlayerControlsStyle.youtube,
    this.controlsHideDelay = const Duration(seconds: 3),
    this.allowFullscreen = true,
    this.allowSpeedControl = true,
    // Gestures
    this.enableDoubleTapSeek = true,
    this.doubleTapSeekSeconds = 10,
    this.enableBrightnessGesture = true,
    this.enableVolumeGesture = true,
    this.enablePinchZoom = false,
    // Subtitles
    this.subtitles = const [],
    this.defaultSubtitleIndex = -1,
    // Audio
    this.audioTracks = const [],
    this.defaultAudioTrackIndex = 0,
    // Cache
    this.enableCache = true,
    this.nextVideoUrl,
    // Background
    this.enableBackgroundPlayback = false,
    // Download
    this.showDownloadButton = false,
    // Thumbnail
    this.thumbnailUrl,
    this.placeholder,
    // DRM
    this.drmConfig,
    // Theme
    this.theme,
    // Callbacks
    this.onReady,
    this.onPlay,
    this.onPause,
    this.onComplete,
    this.onError,
    this.onPositionChanged,
  });

  /// Simple network video — one liner!
  ///
  /// ```dart
  /// SmartPlayerConfig.network('https://example.com/video.mp4')
  /// ```
  factory SmartPlayerConfig.network(
      String url, {
        bool autoPlay = true,
        bool resumePlayback = false,
        String? resumeKey,
        bool enableBackgroundPlayback = false, // 👈 ADD THIS
        SmartPlayerControlsStyle controlsStyle =
            SmartPlayerControlsStyle.youtube,
        SmartPlayerTheme? theme,
        VoidCallback? onComplete,
      }) {
    return SmartPlayerConfig(
      url: url,
      sourceType: SmartPlayerSourceType.network,
      autoPlay: autoPlay,
      resumePlayback: resumePlayback,
      resumeKey: resumeKey,
      enableBackgroundPlayback:
      enableBackgroundPlayback, // 👈 ADD THIS
      controlsStyle: controlsStyle,
      theme: theme,
      onComplete: onComplete,
    );
  }

  /// HLS stream ke liye
  factory SmartPlayerConfig.hls(
      String url, {
        bool autoPlay = true,
        bool resumePlayback = false,
        List<SubtitleTrack> subtitles = const [],
        List<AudioTrack> audioTracks = const [],
        SmartPlayerTheme? theme,
      }) {
    return SmartPlayerConfig(
      url: url,
      sourceType: SmartPlayerSourceType.hls,
      autoPlay: autoPlay,
      resumePlayback: resumePlayback,
      subtitles: subtitles,
      audioTracks: audioTracks,
      theme: theme,
    );
  }

  /// Local file ke liye
  factory SmartPlayerConfig.file(String filePath) {
    return SmartPlayerConfig(
      url: filePath,
      sourceType: SmartPlayerSourceType.file,
    );
  }

  /// Asset ke liye
  factory SmartPlayerConfig.asset(String assetPath) {
    return SmartPlayerConfig(
      url: assetPath,
      sourceType: SmartPlayerSourceType.asset,
    );
  }

  SmartPlayerConfig copyWith({
    String? url,
    SmartPlayerSourceType? sourceType,
    bool? autoPlay,
    bool? loop,
    double? volume,
    double? playbackSpeed,
    Duration? startPosition,
    bool? resumePlayback,
    String? resumeKey,
    SmartPlayerControlsStyle? controlsStyle,
    SmartPlayerTheme? theme,
  }) {
    return SmartPlayerConfig(
      url: url ?? this.url,
      sourceType: sourceType ?? this.sourceType,
      autoPlay: autoPlay ?? this.autoPlay,
      loop: loop ?? this.loop,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      startPosition: startPosition ?? this.startPosition,
      resumePlayback: resumePlayback ?? this.resumePlayback,
      resumeKey: resumeKey ?? this.resumeKey,
      controlsStyle: controlsStyle ?? this.controlsStyle,
      theme: theme ?? this.theme,
    );
  }
}