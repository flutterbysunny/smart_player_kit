import 'package:shared_preferences/shared_preferences.dart';

/// Netflix-style auto resume — last watched position save/load karo
class ResumeManager {
  static const String _prefix = 'smart_player_resume_';

  /// Position save karo
  Future<void> savePosition(String videoKey, Duration position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        '$_prefix$videoKey',
        position.inMilliseconds,
      );
    } catch (_) {
      // Silently ignore storage errors
    }
  }

  /// Saved position load karo
  Future<Duration?> getSavedPosition(String videoKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt('$_prefix$videoKey');
      if (millis == null || millis <= 0) return null;
      return Duration(milliseconds: millis);
    } catch (_) {
      return null;
    }
  }

  /// Ek video ka saved position delete karo
  Future<void> clearPosition(String videoKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$videoKey');
    } catch (_) {}
  }

  /// Sab resume data clear karo
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }

  /// Sab watch history lo
  Future<Map<String, Duration>> getAllPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = <String, Duration>{};
      for (final key in prefs.getKeys()) {
        if (key.startsWith(_prefix)) {
          final millis = prefs.getInt(key);
          if (millis != null && millis > 0) {
            final videoKey = key.replaceFirst(_prefix, '');
            result[videoKey] = Duration(milliseconds: millis);
          }
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }
}