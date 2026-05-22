/// Audio track model — Hindi, English, Tamil etc.
class AudioTrack {
  /// Display label (e.g. "Hindi", "English")
  final String label;

  /// BCP-47 language code
  final String languageCode;

  /// HLS track index ya separate audio URL
  final int? hlsTrackIndex;
  final String? audioUrl;

  const AudioTrack({
    required this.label,
    required this.languageCode,
    this.hlsTrackIndex,
    this.audioUrl,
  });
}