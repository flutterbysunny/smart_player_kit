import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../../smart_player_kit.dart';
import '../background/background_service.dart';
import '../background/notification_controls.dart';

/// SmartPlayer ka main controller
class SmartPlayerController extends ValueNotifier<SmartPlayerValue> {
  SmartPlayerConfig config;

  VideoPlayerController? _videoController;
  SmartPlayerValue _value = const SmartPlayerValue.uninitialized();

  final ResumeManager _resumeManager = ResumeManager();
  final PlayerAnalytics _analytics = PlayerAnalytics();

  /// Subtitle controller — publicly accessible
  final SubtitleController subtitleController = SubtitleController();

  Timer? _positionTimer;
  Timer? _controlsHideTimer;
  bool _controlsVisible = true;

  bool get controlsVisible => _controlsVisible;

  @override
  SmartPlayerValue get value => _value;

  VideoPlayerController? get videoController => _videoController;

  bool get isPlaying    => _value.isPlaying;
  bool get isPaused     => _value.isPaused;
  bool get isBuffering  => _value.isBuffering;
  bool get isInitialized => _value.isInitialized;
  bool get isCompleted  => _value.isCompleted;
  bool get hasError     => _value.hasError;
  Duration get position => _value.position;
  Duration get duration => _value.duration;
  double get progress   => _value.progress;
  double get playbackSpeed => _value.playbackSpeed;

  SmartPlayerController({required this.config})
      : super(const SmartPlayerValue.uninitialized());

  // ─── Initialize ───────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // ✅ Pehle purana sab cancel karo — double timer fix
    _positionTimer?.cancel();
    _positionTimer = null;
    _controlsHideTimer?.cancel();
    _videoController?.removeListener(_onVideoChanged);
    await _videoController?.dispose();
    _videoController = null;

    _updateValue(_value.copyWith(status: SmartPlayerStatus.initializing));

    try {
      _videoController = _buildVideoController();
      await _videoController!.initialize();

      final aspectRatio = _videoController!.value.aspectRatio;

      // Resume position
      Duration startPos = config.startPosition;
      if (config.resumePlayback) {
        final key = config.resumeKey ?? config.url;
        final saved = await _resumeManager.getSavedPosition(key);
        if (saved != null && saved > Duration.zero) startPos = saved;
      }

      _updateValue(_value.copyWith(
        status: SmartPlayerStatus.paused,
        duration: _videoController!.value.duration,
        aspectRatio: aspectRatio,
      ));

      _videoController!.addListener(_onVideoChanged);

      if (startPos > Duration.zero) await _videoController!.seekTo(startPos);
      if (config.playbackSpeed != 1.0) {
        await _videoController!.setPlaybackSpeed(config.playbackSpeed);
      }
      await _videoController!.setVolume(config.volume);

      // Subtitle tracks load karo
      if (config.subtitles.isNotEmpty) {
        subtitleController.setTracks(
          config.subtitles,
          defaultIndex: config.defaultSubtitleIndex,
        );
      }

      // Background playback setup
      if (config.enableBackgroundPlayback) {
        await BackgroundService.instance.setup(this);
        await NotificationControls.init();
        NotificationControls.bindController(this);
      }

      _analytics.onVideoLoaded(config.url, _value.duration);
      config.onReady?.call();

      if (config.autoPlay) await play();

      _startPositionTimer();
    } catch (e) {
      _updateValue(SmartPlayerValue.error(e.toString()));
      config.onError?.call(e.toString());
    }
  }

  VideoPlayerController _buildVideoController() {
    switch (config.sourceType) {
      case SmartPlayerSourceType.network:
      case SmartPlayerSourceType.hls:
        return VideoPlayerController.networkUrl(
          Uri.parse(config.url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      case SmartPlayerSourceType.file:
        return VideoPlayerController.contentUri(Uri.parse(config.url));
      case SmartPlayerSourceType.asset:
        return VideoPlayerController.asset(config.url);
    }
  }

  // ─── Playback ─────────────────────────────────────────────────────────────

  Future<void> play() async {
    if (_videoController == null) return;
    await _videoController!.play();
    _updateValue(_value.copyWith(status: SmartPlayerStatus.playing));
    _analytics.onPlay(position);
    config.onPlay?.call();
    _startControlsHideTimer();

    if (config.enableBackgroundPlayback) {
      await NotificationControls.show(
        title: config.url.split('/').last,
        artist: 'SmartPlayerKit',
        isPlaying: true,
      );
    }
  }

  Future<void> pause() async {
    if (_videoController == null) return;
    await _videoController!.pause();
    _updateValue(_value.copyWith(status: SmartPlayerStatus.paused));
    _analytics.onPause(position);
    config.onPause?.call();
    _cancelControlsHideTimer();

    if (config.enableBackgroundPlayback) {
      await NotificationControls.show(
        title: config.url.split('/').last,
        artist: 'SmartPlayerKit',
        isPlaying: false,
      );
    }
  }

  Future<void> togglePlayPause() async =>
      isPlaying ? pause() : play();

  Future<void> seekTo(Duration pos) async {
    if (_videoController == null) return;
    final clamped = Duration(
      milliseconds:
      pos.inMilliseconds.clamp(0, duration.inMilliseconds).toInt(),
    );
    await _videoController!.seekTo(clamped);
    _updateValue(_value.copyWith(position: clamped));
    subtitleController.updatePosition(clamped);
    _analytics.onSeek(clamped);
  }

  Future<void> seekForward([int seconds = 10]) async =>
      seekTo(position + Duration(seconds: seconds));

  Future<void> seekBackward([int seconds = 10]) async =>
      seekTo(position - Duration(seconds: seconds));

  Future<void> setPlaybackSpeed(double speed) async {
    if (_videoController == null) return;
    final s = speed.clamp(0.25, 3.0);
    await _videoController!.setPlaybackSpeed(s);
    _updateValue(_value.copyWith(playbackSpeed: s));
  }

  Future<void> setVolume(double volume) async {
    if (_videoController == null) return;
    final v = volume.clamp(0.0, 1.0);
    await _videoController!.setVolume(v);
    _updateValue(_value.copyWith(volume: v, isMuted: v == 0));
  }

  Future<void> toggleMute() async =>
      _value.isMuted ? setVolume(1.0) : setVolume(0.0);

  void toggleFullscreen() =>
      _updateValue(_value.copyWith(isFullscreen: !_value.isFullscreen));

  // ─── Controls Visibility ──────────────────────────────────────────────────

  void showControls() {
    _controlsVisible = true;
    notifyListeners();
    if (isPlaying) _startControlsHideTimer();
  }

  void hideControls() {
    _controlsVisible = false;
    _cancelControlsHideTimer();
    notifyListeners();
  }

  void toggleControls() =>
      _controlsVisible ? hideControls() : showControls();

  void _startControlsHideTimer() {
    _cancelControlsHideTimer();
    _controlsHideTimer = Timer(config.controlsHideDelay, () {
      if (isPlaying) hideControls();
    });
  }

  void _cancelControlsHideTimer() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = null;
  }

  // ─── Load New Video ────────────────────────────────────────────────────────

  Future<void> loadNewVideo(SmartPlayerConfig newConfig) async {
    if (config.resumePlayback) await _savePosition();
    config = newConfig;
    await _videoController?.dispose();
    _videoController = null;
    _value = const SmartPlayerValue.uninitialized();
    await initialize();
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  void _onVideoChanged() {
    if (_videoController == null) return;
    final v = _videoController!.value;

    SmartPlayerStatus status;
    if (v.hasError) {
      status = SmartPlayerStatus.error;
      config.onError?.call(v.errorDescription ?? 'Unknown error');
    } else if (v.isBuffering) {
      status = SmartPlayerStatus.buffering;
    } else if (v.isPlaying) {
      status = SmartPlayerStatus.playing;
    } else if (v.position >= v.duration && v.duration > Duration.zero) {
      status = SmartPlayerStatus.completed;
      _onCompleted();
    } else {
      status = SmartPlayerStatus.paused;
    }

    _updateValue(_value.copyWith(
      position: v.position,
      duration: v.duration,
      status: status,
      errorMessage: v.hasError ? v.errorDescription : null,
    ));

    subtitleController.updatePosition(v.position);
    config.onPositionChanged?.call(v.position);
  }

  void _onCompleted() {
    _analytics.onComplete(duration);
    config.onComplete?.call();
    NotificationControls.dismiss();
    if (config.loop) {
      seekTo(Duration.zero);
      play();
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (config.resumePlayback) _savePosition();
    });
  }

  Future<void> _savePosition() async {
    if (_value.isInitialized && position > Duration.zero) {
      final key = config.resumeKey ?? config.url;
      await _resumeManager.savePosition(key, position);
    }
  }

  void _updateValue(SmartPlayerValue v) {
    _value = v;
    notifyListeners();
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────

  @override
  Future<void> dispose() async {
    if (config.resumePlayback) await _savePosition();
    _positionTimer?.cancel();
    _controlsHideTimer?.cancel();
    _videoController?.removeListener(_onVideoChanged);
    await _videoController?.dispose();
    await NotificationControls.dismiss();
    subtitleController.dispose();
    _updateValue(_value.copyWith(status: SmartPlayerStatus.disposed));
    super.dispose();
  }
}