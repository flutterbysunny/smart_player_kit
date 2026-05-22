import 'package:flutter/foundation.dart';
import 'package:audio_session/audio_session.dart';

import '../../smart_player_kit.dart';

/// Background playback service
/// App minimize hone par bhi audio/video chalata rahe
class BackgroundService {
  static BackgroundService? _instance;
  static BackgroundService get instance => _instance ??= BackgroundService._();
  BackgroundService._();

  AudioSession? _audioSession;
  SmartPlayerController? _activeController;
  bool _isSetup = false;

  /// Background playback setup karo
  Future<void> setup(SmartPlayerController controller) async {
    _activeController = controller;
    if (_isSetup) return;

    try {
      _audioSession = await AudioSession.instance;

      await _audioSession!.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
        AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.moviePlayback,
        avAudioSessionRouteSharingPolicy:
        AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions:
        AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.movie,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      // Call aane par pause
      _audioSession!.interruptionEventStream.listen((event) {
        if (event.begin) {
          _activeController?.pause();
        } else {
          if (event.type == AudioInterruptionType.pause ||
              event.type == AudioInterruptionType.duck) {
            _activeController?.play();
          }
        }
      });

      // Headphone unplug — auto pause
      _audioSession!.becomingNoisyEventStream.listen((_) {
        _activeController?.pause();
      });

      await _audioSession!.setActive(true);
      _isSetup = true;
      debugPrint('SmartPlayer: Background service ready ✅');
    } catch (e) {
      debugPrint('SmartPlayer: Background setup failed — $e');
    }
  }

  void updateController(SmartPlayerController controller) {
    _activeController = controller;
  }

  Future<void> dispose() async {
    try {
      await _audioSession?.setActive(false);
    } catch (_) {}
    _activeController = null;
    _isSetup = false;
    _instance = null;
  }
}