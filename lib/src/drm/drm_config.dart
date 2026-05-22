/// DRM Configuration — Widevine (Android) aur FairPlay (iOS)
class DrmConfig {
  /// License server URL
  final String licenseUrl;

  /// DRM type
  final DrmType type;

  /// Custom headers for license request
  final Map<String, String>? headers;

  const DrmConfig({
    required this.licenseUrl,
    required this.type,
    this.headers,
  });

  /// Widevine (Android) — L1/L3
  factory DrmConfig.widevine(String licenseUrl,
      {Map<String, String>? headers}) {
    return DrmConfig(
      licenseUrl: licenseUrl,
      type: DrmType.widevine,
      headers: headers,
    );
  }

  /// FairPlay (iOS)
  factory DrmConfig.fairplay(String licenseUrl,
      {Map<String, String>? headers}) {
    return DrmConfig(
      licenseUrl: licenseUrl,
      type: DrmType.fairplay,
      headers: headers,
    );
  }
}

enum DrmType { widevine, fairplay, playready }