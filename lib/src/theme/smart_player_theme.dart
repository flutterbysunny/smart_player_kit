import 'package:flutter/material.dart';

/// SmartPlayer ka complete theme — developer apni marzi ka UI bana sake
class SmartPlayerTheme {
  // ─── Colors ───────────────────────────────────────────────────────────────

  /// Main accent color (progress bar, buttons)
  final Color primaryColor;

  /// Controls background color
  final Color controlsBackgroundColor;

  /// Controls icons ka color
  final Color iconColor;

  /// Progress bar background color
  final Color progressBarBackgroundColor;

  /// Progress bar fill color
  final Color progressBarColor;

  /// Buffer indicator color
  final Color bufferColor;

  /// Subtitle text color
  final Color subtitleTextColor;

  /// Subtitle background color
  final Color subtitleBackgroundColor;

  // ─── Typography ───────────────────────────────────────────────────────────

  /// Subtitle text style
  final TextStyle subtitleTextStyle;

  /// Time text style (position / duration)
  final TextStyle timeTextStyle;

  /// Title text style
  final TextStyle titleTextStyle;

  // ─── Sizes ────────────────────────────────────────────────────────────────

  /// Play/Pause button size
  final double playButtonSize;

  /// Controls icons ka size
  final double iconSize;

  /// Progress bar height
  final double progressBarHeight;

  /// Subtitle font size
  final double subtitleFontSize;

  // ─── Border Radius ────────────────────────────────────────────────────────

  /// Overall player border radius
  final double playerBorderRadius;

  const SmartPlayerTheme({
    this.primaryColor = const Color(0xFFFF0000),
    this.controlsBackgroundColor = const Color(0x80000000),
    this.iconColor = Colors.white,
    this.progressBarBackgroundColor = const Color(0x4DFFFFFF),
    this.progressBarColor = const Color(0xFFFF0000),
    this.bufferColor = const Color(0x80FFFFFF),
    this.subtitleTextColor = Colors.white,
    this.subtitleBackgroundColor = const Color(0x80000000),
    this.subtitleTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
    ),
    this.timeTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    this.titleTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    this.playButtonSize = 54,
    this.iconSize = 24,
    this.progressBarHeight = 3,
    this.subtitleFontSize = 16,
    this.playerBorderRadius = 0,
  });

  /// Netflix jaisa dark red theme
  factory SmartPlayerTheme.netflix() {
    return const SmartPlayerTheme(
      primaryColor: Color(0xFFE50914),
      progressBarColor: Color(0xFFE50914),
      controlsBackgroundColor: Color(0x99000000),
    );
  }

  /// YouTube jaisa red theme
  factory SmartPlayerTheme.youtube() {
    return const SmartPlayerTheme(
      primaryColor: Color(0xFFFF0000),
      progressBarColor: Color(0xFFFF0000),
    );
  }

  /// Pure white minimal theme
  factory SmartPlayerTheme.minimal() {
    return const SmartPlayerTheme(
      primaryColor: Colors.white,
      progressBarColor: Colors.white,
      iconColor: Colors.white,
      progressBarHeight: 2,
      playButtonSize: 44,
      iconSize: 20,
    );
  }

  SmartPlayerTheme copyWith({
    Color? primaryColor,
    Color? controlsBackgroundColor,
    Color? iconColor,
    Color? progressBarColor,
    Color? subtitleTextColor,
    double? playButtonSize,
    double? iconSize,
    double? progressBarHeight,
    double? playerBorderRadius,
  }) {
    return SmartPlayerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      controlsBackgroundColor:
      controlsBackgroundColor ?? this.controlsBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
      progressBarColor: progressBarColor ?? this.progressBarColor,
      subtitleTextColor: subtitleTextColor ?? this.subtitleTextColor,
      playButtonSize: playButtonSize ?? this.playButtonSize,
      iconSize: iconSize ?? this.iconSize,
      progressBarHeight: progressBarHeight ?? this.progressBarHeight,
      playerBorderRadius: playerBorderRadius ?? this.playerBorderRadius,
    );
  }
}