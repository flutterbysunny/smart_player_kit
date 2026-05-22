/// Player analytics — watch duration, completion %, pause count track karo
class PlayerAnalytics {
  String? _currentVideoUrl;
  Duration _totalDuration = Duration.zero;
  Duration _watchedDuration = Duration.zero;
  Duration _lastPlayPosition = Duration.zero;
  int _pauseCount = 0;
  int _seekCount = 0;
  DateTime? _playStartTime;
  bool _isPlaying = false;

  /// Analytics event callback — developer ko data milta hai
  void Function(AnalyticsEvent event)? onEvent;

  void onVideoLoaded(String url, Duration duration) {
    _currentVideoUrl = url;
    _totalDuration = duration;
    _watchedDuration = Duration.zero;
    _pauseCount = 0;
    _seekCount = 0;
    _isPlaying = false;
  }

  void onPlay(Duration position) {
    _playStartTime = DateTime.now();
    _lastPlayPosition = position;
    _isPlaying = true;

    onEvent?.call(AnalyticsEvent(
      type: AnalyticsEventType.play,
      position: position,
      videoUrl: _currentVideoUrl,
    ));
  }

  void onPause(Duration position) {
    _accumulateWatchTime(position);
    _pauseCount++;
    _isPlaying = false;

    onEvent?.call(AnalyticsEvent(
      type: AnalyticsEventType.pause,
      position: position,
      videoUrl: _currentVideoUrl,
      pauseCount: _pauseCount,
    ));
  }

  void onSeek(Duration newPosition) {
    _seekCount++;
    if (_isPlaying) {
      _lastPlayPosition = newPosition;
      _playStartTime = DateTime.now();
    }

    onEvent?.call(AnalyticsEvent(
      type: AnalyticsEventType.seek,
      position: newPosition,
      videoUrl: _currentVideoUrl,
    ));
  }

  void onComplete(Duration duration) {
    _accumulateWatchTime(duration);
    _isPlaying = false;

    onEvent?.call(AnalyticsEvent(
      type: AnalyticsEventType.complete,
      position: duration,
      videoUrl: _currentVideoUrl,
      watchedDuration: _watchedDuration,
      completionPercent: completionPercent,
      pauseCount: _pauseCount,
      seekCount: _seekCount,
    ));
  }

  void _accumulateWatchTime(Duration currentPosition) {
    if (_playStartTime != null && _isPlaying) {
      final sessionDuration = DateTime.now().difference(_playStartTime!);
      _watchedDuration += sessionDuration;
      _playStartTime = null;
    }
  }

  /// Kitna % dekha gaya (0.0 to 100.0)
  double get completionPercent {
    if (_totalDuration <= Duration.zero) return 0.0;
    return (_watchedDuration.inMilliseconds /
        _totalDuration.inMilliseconds *
        100)
        .clamp(0.0, 100.0);
  }

  /// Total watched time
  Duration get watchedDuration => _watchedDuration;

  /// Pause kitni baar hua
  int get pauseCount => _pauseCount;

  /// Seek kitni baar hua
  int get seekCount => _seekCount;

  /// Current video ka summary
  Map<String, dynamic> get summary => {
    'url': _currentVideoUrl,
    'totalDuration': _totalDuration.inSeconds,
    'watchedDuration': _watchedDuration.inSeconds,
    'completionPercent': completionPercent,
    'pauseCount': _pauseCount,
    'seekCount': _seekCount,
  };
}

enum AnalyticsEventType { play, pause, seek, complete, error }

class AnalyticsEvent {
  final AnalyticsEventType type;
  final Duration position;
  final String? videoUrl;
  final Duration? watchedDuration;
  final double? completionPercent;
  final int? pauseCount;
  final int? seekCount;
  final String? errorMessage;

  const AnalyticsEvent({
    required this.type,
    required this.position,
    this.videoUrl,
    this.watchedDuration,
    this.completionPercent,
    this.pauseCount,
    this.seekCount,
    this.errorMessage,
  });
}