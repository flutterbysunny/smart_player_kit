/// Subtitle track model
class SubtitleTrack {
  /// Display label (e.g. "English", "Hindi")
  final String label;

  /// BCP-47 language code (e.g. "en", "hi")
  final String languageCode;

  /// URL to .srt or .vtt file
  final String url;

  /// SRT ya WEBVTT
  final SubtitleFormat format;

  const SubtitleTrack({
    required this.label,
    required this.languageCode,
    required this.url,
    this.format = SubtitleFormat.webvtt,
  });
}

enum SubtitleFormat { srt, webvtt }