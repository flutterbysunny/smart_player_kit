import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'smart_player_kit_platform_interface.dart';

/// An implementation of [SmartPlayerKitPlatform] that uses method channels.
class MethodChannelSmartPlayerKit extends SmartPlayerKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('smart_player_kit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
