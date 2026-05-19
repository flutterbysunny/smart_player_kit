import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'smart_player_kit_method_channel.dart';

abstract class SmartPlayerKitPlatform extends PlatformInterface {
  /// Constructs a SmartPlayerKitPlatform.
  SmartPlayerKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmartPlayerKitPlatform _instance = MethodChannelSmartPlayerKit();

  /// The default instance of [SmartPlayerKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmartPlayerKit].
  static SmartPlayerKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SmartPlayerKitPlatform] when
  /// they register themselves.
  static set instance(SmartPlayerKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
