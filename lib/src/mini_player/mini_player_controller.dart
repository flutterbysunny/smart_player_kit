import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Mini player ke saare states
enum MiniPlayerState {
  /// Player bilkul hidden hai
  hidden,

  /// Mini floating player visible hai (bottom-right corner)
  minimized,

  /// Full screen player open hai
  expanded,
}

/// YouTube-style MiniPlayer ka state — SmartPlayerController ke saath share hota hai
class MiniPlayerValue {
  const MiniPlayerValue({
    this.state = MiniPlayerState.hidden,
    this.dragOffset = Offset.zero,
    this.isDragging = false,
    this.videoTitle = '',
    this.videoSubtitle = '',
    this.thumbnailUrl,
  });

  final MiniPlayerState state;

  /// User ne drag karke kitna move kiya hai (screen coordinates)
  final Offset dragOffset;

  final bool isDragging;

  /// Mini player mein dikhne wala title
  final String videoTitle;

  /// Artist / channel name
  final String videoSubtitle;

  /// Optional thumbnail — jab tak video load nahi hoti
  final String? thumbnailUrl;

  bool get isHidden => state == MiniPlayerState.hidden;
  bool get isMinimized => state == MiniPlayerState.minimized;
  bool get isExpanded => state == MiniPlayerState.expanded;

  MiniPlayerValue copyWith({
    MiniPlayerState? state,
    Offset? dragOffset,
    bool? isDragging,
    String? videoTitle,
    String? videoSubtitle,
    String? thumbnailUrl,
  }) {
    return MiniPlayerValue(
      state: state ?? this.state,
      dragOffset: dragOffset ?? this.dragOffset,
      isDragging: isDragging ?? this.isDragging,
      videoTitle: videoTitle ?? this.videoTitle,
      videoSubtitle: videoSubtitle ?? this.videoSubtitle,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MiniPlayerValue &&
              runtimeType == other.runtimeType &&
              state == other.state &&
              dragOffset == other.dragOffset &&
              isDragging == other.isDragging &&
              videoTitle == other.videoTitle &&
              videoSubtitle == other.videoSubtitle &&
              thumbnailUrl == other.thumbnailUrl;

  @override
  int get hashCode => Object.hash(
    state,
    dragOffset,
    isDragging,
    videoTitle,
    videoSubtitle,
    thumbnailUrl,
  );
}

/// MiniPlayer ka brain — SmartPlayerController ke saath milke kaam karta hai.
///
/// Usage:
/// ```dart
/// final miniController = MiniPlayerController();
///
/// // Video play karo aur mini player dikhao
/// miniController.openMiniPlayer(
///   title: 'Har Har Shambhu',
///   subtitle: 'Ajay-Atul',
/// );
///
/// // Full player kholna
/// miniController.expand();
///
/// // Band karna
/// miniController.close();
/// ```
class MiniPlayerController extends ValueNotifier<MiniPlayerValue> {
  MiniPlayerController() : super(const MiniPlayerValue());

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Mini player ko show karo (minimized state mein)
  void openMiniPlayer({
    required String title,
    String subtitle = '',
    String? thumbnailUrl,
  }) {
    value = value.copyWith(
      state: MiniPlayerState.minimized,
      videoTitle: title,
      videoSubtitle: subtitle,
      thumbnailUrl: thumbnailUrl,
      dragOffset: Offset.zero,
    );
  }

  /// Mini player se full player pe jao
  void expand() {
    if (value.isHidden) return;
    value = value.copyWith(
      state: MiniPlayerState.expanded,
      dragOffset: Offset.zero,
      isDragging: false,
    );
  }

  /// Full player se mini player pe wapas jao
  void minimize() {
    if (value.isHidden) return;
    value = value.copyWith(
      state: MiniPlayerState.minimized,
      dragOffset: Offset.zero,
      isDragging: false,
    );
  }

  /// Mini player aur video dono band karo
  void close() {
    value = const MiniPlayerValue(state: MiniPlayerState.hidden);
  }

  /// Drag shuru hone par call karo
  void onDragStart() {
    value = value.copyWith(isDragging: true);
  }

  /// Drag update par position update karo
  void onDragUpdate(Offset delta) {
    value = value.copyWith(
      dragOffset: value.dragOffset + delta,
      isDragging: true,
    );
  }

  /// Drag khatam — snap karo ya dismiss karo
  ///
  /// [screenSize] — full screen ka size (snap logic ke liye)
  /// [dismissThreshold] — kitna neeche drag ho to close ho jaye (default 100px)
  void onDragEnd({
    required Size screenSize,
    double dismissThreshold = 100.0,
  }) {
    final offset = value.dragOffset;

    // Neeche zyada drag kiya to close
    if (offset.dy > dismissThreshold) {
      close();
      return;
    }

    // Baaki cases mein origin pe snap back
    value = value.copyWith(
      dragOffset: Offset.zero,
      isDragging: false,
    );
  }

  /// Title/subtitle update karo (naya video select hone par)
  void updateMediaInfo({
    required String title,
    String? subtitle,
    String? thumbnailUrl,
  }) {
    value = value.copyWith(
      videoTitle: title,
      videoSubtitle: subtitle,
      thumbnailUrl: thumbnailUrl,
    );
  }
}