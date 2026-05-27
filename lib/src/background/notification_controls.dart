import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../smart_player_kit.dart';

// ✅ Top-level function — v21 requirement
@pragma('vm:entry-point')
void _onNotificationAction(NotificationResponse response) {
  NotificationControls._handleAction(response);
}

/// Lock screen + notification bar mein play/pause/seek controls dikhao
class NotificationControls {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const int _notifId = 7788;

  /// Notification system initialize karo — app start mein ek baar
  static Future<void> init() async {
    if (_initialized) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // ✅ Fix 1: settings: named parameter
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onNotificationAction,
        onDidReceiveBackgroundNotificationResponse: _onNotificationAction,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('SmartPlayer: Notification init failed — $e');
    }
  }

  /// Media notification show karo
  static Future<void> show({
    required String title,
    required String artist,
    required bool isPlaying,
  }) async {
    if (!_initialized) return;
    try {
      final android = AndroidNotificationDetails(
        'smart_player_media',
        'Media Playback',
        channelDescription: 'SmartPlayer media controls',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        playSound: false,
        enableVibration: false,
        showWhen: false,
        actions: [
          // ✅ Fix 2: 2 positional args — id, title
          const AndroidNotificationAction(
            'action_prev',
            '',
            icon: DrawableResourceAndroidBitmap('@drawable/ic_skip_previous'),
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            'action_play_pause',
            '',
            icon: DrawableResourceAndroidBitmap(
              isPlaying ? '@drawable/ic_pause' : '@drawable/ic_play',
            ),
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            'action_next',
            '',
            icon: DrawableResourceAndroidBitmap('@drawable/ic_skip_next'),
            showsUserInterface: false,
          ),
        ],
      );

      // ✅ Fix 3: id: named parameter
      await _plugin.show(
        id: _notifId,
        title: title,
        body: artist,
        notificationDetails: NotificationDetails(android: android),
      );
    } catch (e) {
      debugPrint('SmartPlayer: Notification show failed — $e');
    }
  }

  /// Notification dismiss karo
  static Future<void> dismiss() async {
    try {
      // ✅ Fix 4: id: named parameter
      await _plugin.cancel(id: _notifId);
    } catch (_) {}
  }

  // ── Controller binding ────────────────────────────────────
  static SmartPlayerController? _controller;

  static void bindController(SmartPlayerController ctrl) {
    _controller = ctrl;
  }

  static void _handleAction(NotificationResponse response) {
    final ctrl = _controller;
    if (ctrl == null) return;

    switch (response.actionId) {
      case 'action_play_pause':
        ctrl.togglePlayPause();
        break;
      case 'action_prev':
        ctrl.seekBackward(10);
        break;
      case 'action_next':
        ctrl.seekForward(10);
        break;
    }
  }
}