import 'package:flutter/material.dart';
import '../subtitle/subtitle_track.dart';
import '../audio_tracks/audio_track.dart';
import '../drm/drm_config.dart';
import '../theme/smart_player_theme.dart';

/// Video source ka type
enum SmartPlayerSourceType {
  network,
  hls,
  file,
  asset,
}

/// Controls ka style
enum SmartPlayerControlsStyle {
  netflix,
  youtube,
  minimal,
  reels,
  none,
}

/// SmartPlayer ka complete configuration
class SmartPlayerConfig {
  // ─── Source ───────────────────────────────────────────────────────────────
  final String url;
  final SmartPlayerSourceType sourceType;

  // ─── Playback ─────────────────────────────────────────────────────────────
  final bool autoPlay;
  final bool loop;
  final double volume;
  final double playbackSpeed;
  final Duration startPosition;

  // ─── Resume ───────────────────────────────────────────────────────────────
  final bool resumePlayback;
  final String? resumeKey;

  // ─── Controls ─────────────────────────────────────────────────────────────
  final SmartPlayerControlsStyle controlsStyle;
  final Duration controlsHideDelay;
  final bool allowFullscreen;
  final bool allowSpeedControl;

  // ─── Gestures ─────────────────────────────────────────────────────────────
  final bool enableDoubleTapSeek;
  final int doubleTapSeekSeconds;
  final bool enableBrightnessGesture;
  final bool enableVolumeGesture;
  final bool enablePinchZoom;

  // ─── Subtitles ────────────────────────────────────────────────────────────
  final List<SubtitleTrack> subtitles;
  final int defaultSubtitleIndex;

  // ─── Audio Tracks ─────────────────────────────────────────────────────────
  final List<AudioTrack> audioTracks;
  final int defaultAudioTrackIndex;

  // ─── Cache ────────────────────────────────────────────────────────────────
  final bool enableCache;
  final String? nextVideoUrl;

  // ─── Background ───────────────────────────────────────────────────────────
  final bool enableBackgroundPlayback;

  // ─── Download ─────────────────────────────────────────────────────────────
  final bool showDownloadButton;

  // ─── Thumbnail ────────────────────────────────────────────────────────────
  final String? thumbnailUrl;
  final Widget? placeholder;

  // ─── DRM ──────────────────────────────────────────────────────────────────
  final DrmConfig? drmConfig;

  // ─── Theme ────────────────────────────────────────────────────────────────
  final SmartPlayerTheme? theme;

  // ─── Callbacks ────────────────────────────────────────────────────────────
  final VoidCallback? onReady;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onComplete;
  final void Function(String error)? onError;
  final void Function(Duration position)? onPositionChanged;

  /// ✅ Developer apna custom subtitle UI dena chahta hai toh ye pass karo
  /// null = default bottom sheet open hoga
  final VoidCallback? onSubtitleTap;

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
    this.onSubtitleTap,
  });

  // ─── Named Constructors ───────────────────────────────────────────────────

  factory SmartPlayerConfig.network(
      String url, {
        bool autoPlay = true,
        bool resumePlayback = false,
        String? resumeKey,
        bool enableBackgroundPlayback = false,
        SmartPlayerControlsStyle controlsStyle = SmartPlayerControlsStyle.youtube,
        SmartPlayerTheme? theme,
        VoidCallback? onComplete,
        VoidCallback? onSubtitleTap,
      }) {
    return SmartPlayerConfig(
      url: url,
      sourceType: SmartPlayerSourceType.network,
      autoPlay: autoPlay,
      resumePlayback: resumePlayback,
      resumeKey: resumeKey,
      enableBackgroundPlayback: enableBackgroundPlayback,
      controlsStyle: controlsStyle,
      theme: theme,
      onComplete: onComplete,
      onSubtitleTap: onSubtitleTap,
    );
  }

  factory SmartPlayerConfig.hls(
      String url, {
        bool autoPlay = true,
        bool resumePlayback = false,
        List<SubtitleTrack> subtitles = const [],
        List<AudioTrack> audioTracks = const [],
        SmartPlayerTheme? theme,
        VoidCallback? onSubtitleTap,
      }) {
    return SmartPlayerConfig(
      url: url,
      sourceType: SmartPlayerSourceType.hls,
      autoPlay: autoPlay,
      resumePlayback: resumePlayback,
      subtitles: subtitles,
      audioTracks: audioTracks,
      theme: theme,
      onSubtitleTap: onSubtitleTap,
    );
  }

  factory SmartPlayerConfig.file(String filePath) {
    return SmartPlayerConfig(
      url: filePath,
      sourceType: SmartPlayerSourceType.file,
    );
  }

  factory SmartPlayerConfig.asset(String assetPath) {
    return SmartPlayerConfig(
      url: assetPath,
      sourceType: SmartPlayerSourceType.asset,
    );
  }

  // ─── copyWith ─────────────────────────────────────────────────────────────

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
    bool? enableBackgroundPlayback,
    SmartPlayerControlsStyle? controlsStyle,
    Duration? controlsHideDelay,
    bool? allowFullscreen,
    bool? allowSpeedControl,
    bool? enableDoubleTapSeek,
    int? doubleTapSeekSeconds,
    bool? enableBrightnessGesture,
    bool? enableVolumeGesture,
    bool? enablePinchZoom,
    List<SubtitleTrack>? subtitles,
    int? defaultSubtitleIndex,
    List<AudioTrack>? audioTracks,
    int? defaultAudioTrackIndex,
    bool? enableCache,
    String? nextVideoUrl,
    bool? showDownloadButton,
    String? thumbnailUrl,
    Widget? placeholder,
    DrmConfig? drmConfig,
    SmartPlayerTheme? theme,
    VoidCallback? onReady,
    VoidCallback? onPlay,
    VoidCallback? onPause,
    VoidCallback? onComplete,
    void Function(String)? onError,
    void Function(Duration)? onPositionChanged,
    VoidCallback? onSubtitleTap,
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
      enableBackgroundPlayback:
      enableBackgroundPlayback ?? this.enableBackgroundPlayback,
      controlsStyle: controlsStyle ?? this.controlsStyle,
      controlsHideDelay: controlsHideDelay ?? this.controlsHideDelay,
      allowFullscreen: allowFullscreen ?? this.allowFullscreen,
      allowSpeedControl: allowSpeedControl ?? this.allowSpeedControl,
      enableDoubleTapSeek: enableDoubleTapSeek ?? this.enableDoubleTapSeek,
      doubleTapSeekSeconds: doubleTapSeekSeconds ?? this.doubleTapSeekSeconds,
      enableBrightnessGesture:
      enableBrightnessGesture ?? this.enableBrightnessGesture,
      enableVolumeGesture: enableVolumeGesture ?? this.enableVolumeGesture,
      enablePinchZoom: enablePinchZoom ?? this.enablePinchZoom,
      subtitles: subtitles ?? this.subtitles,
      defaultSubtitleIndex: defaultSubtitleIndex ?? this.defaultSubtitleIndex,
      audioTracks: audioTracks ?? this.audioTracks,
      defaultAudioTrackIndex:
      defaultAudioTrackIndex ?? this.defaultAudioTrackIndex,
      enableCache: enableCache ?? this.enableCache,
      nextVideoUrl: nextVideoUrl ?? this.nextVideoUrl,
      showDownloadButton: showDownloadButton ?? this.showDownloadButton,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      placeholder: placeholder ?? this.placeholder,
      drmConfig: drmConfig ?? this.drmConfig,
      theme: theme ?? this.theme,
      onReady: onReady ?? this.onReady,
      onPlay: onPlay ?? this.onPlay,
      onPause: onPause ?? this.onPause,
      onComplete: onComplete ?? this.onComplete,
      onError: onError ?? this.onError,
      onPositionChanged: onPositionChanged ?? this.onPositionChanged,
      onSubtitleTap: onSubtitleTap ?? this.onSubtitleTap,
    );
  }
}