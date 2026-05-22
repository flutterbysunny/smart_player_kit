/// Player ke saare possible states
enum SmartPlayerStatus {
  /// Player initialize ho raha hai
  initializing,

  /// Buffer ho raha hai / load ho raha hai
  buffering,

  /// Play ho raha hai
  playing,

  /// Pause hai
  paused,

  /// Video khatam ho gaya
  completed,

  /// Koi error aaya
  error,

  /// Player dispose ho gaya
  disposed,
}

/// Player ki current value — sab kuch ek jagah
class SmartPlayerValue {
  /// Kitna time beet gaya
  final Duration position;

  /// Video kitna lamba hai
  final Duration duration;

  /// Kitna buffer ho gaya hai
  final Duration buffered;

  /// Current player status
  final SmartPlayerStatus status;

  /// Error message (agar koi error ho)
  final String? errorMessage;

  /// Playback speed (0.5 to 2.0)
  final double playbackSpeed;

  /// Volume (0.0 to 1.0)
  final double volume;

  /// Mute hai ya nahi
  final bool isMuted;

  /// Fullscreen hai ya nahi
  final bool isFullscreen;

  /// Video width x height
  final double aspectRatio;

  const SmartPlayerValue({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
    this.status = SmartPlayerStatus.initializing,
    this.errorMessage,
    this.playbackSpeed = 1.0,
    this.volume = 1.0,
    this.isMuted = false,
    this.isFullscreen = false,
    this.aspectRatio = 16 / 9,
  });

  /// Initial empty state
  const SmartPlayerValue.uninitialized()
      : this(status: SmartPlayerStatus.initializing);

  /// Error state
  const SmartPlayerValue.error(String message)
      : this(
    status: SmartPlayerStatus.error,
    errorMessage: message,
  );

  bool get isPlaying => status == SmartPlayerStatus.playing;
  bool get isPaused => status == SmartPlayerStatus.paused;
  bool get isBuffering => status == SmartPlayerStatus.buffering;
  bool get isCompleted => status == SmartPlayerStatus.completed;
  bool get hasError => status == SmartPlayerStatus.error;
  bool get isInitialized => duration > Duration.zero;

  /// Progress 0.0 to 1.0
  double get progress {
    if (duration <= Duration.zero) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Buffer progress 0.0 to 1.0
  double get bufferProgress {
    if (duration <= Duration.zero) return 0.0;
    return (buffered.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  SmartPlayerValue copyWith({
    Duration? position,
    Duration? duration,
    Duration? buffered,
    SmartPlayerStatus? status,
    String? errorMessage,
    double? playbackSpeed,
    double? volume,
    bool? isMuted,
    bool? isFullscreen,
    double? aspectRatio,
  }) {
    return SmartPlayerValue(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffered: buffered ?? this.buffered,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  @override
  String toString() =>
      'SmartPlayerValue(status: $status, position: $position, duration: $duration)';
}