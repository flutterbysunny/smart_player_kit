// lib/src/pip/pip_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum PipStatus { unavailable, available, active, inactive }

class PipValue {
  const PipValue({
    this.status = PipStatus.unavailable,
    this.isSupported = false,
  });

  final PipStatus status;
  final bool isSupported;

  bool get isActive => status == PipStatus.active;
  bool get isAvailable => status == PipStatus.available;

  PipValue copyWith({PipStatus? status, bool? isSupported}) => PipValue(
    status: status ?? this.status,
    isSupported: isSupported ?? this.isSupported,
  );
}

class PipController extends ValueNotifier<PipValue> {
  PipController() : super(const PipValue());

  static const _channel = MethodChannel('smart_player_kit/pip');

  // ✅ PipController mein channel getter — PipValue mein nahi
  MethodChannel get channel => _channel;

  /// PiP support check karo
  Future<void> initialize() async {
    try {
      final supported =
          await _channel.invokeMethod<bool>('isSupported') ?? false;
      value = value.copyWith(
        isSupported: supported,
        status: supported ? PipStatus.available : PipStatus.unavailable,
      );
    } catch (_) {
      value = value.copyWith(status: PipStatus.unavailable);
    }
  }

  /// PiP mode enter karo
  Future<void> enterPip({
    double aspectRatioX = 16,
    double aspectRatioY = 9,
  }) async {
    if (!value.isSupported) return;
    try {
      await _channel.invokeMethod('enterPip', {
        'aspectRatioX': aspectRatioX,
        'aspectRatioY': aspectRatioY,
      });
      value = value.copyWith(status: PipStatus.active);
    } catch (e) {
      debugPrint('SmartPlayer: PiP enter failed — $e');
    }
  }

  /// PiP mode exit karo
  Future<void> exitPip() async {
    try {
      await _channel.invokeMethod('exitPip');
      value = value.copyWith(status: PipStatus.inactive);
    } catch (e) {
      debugPrint('SmartPlayer: PiP exit failed — $e');
    }
  }

  /// PiP status update (native se callback)
  void updateStatus(PipStatus status) {
    value = value.copyWith(status: status);
  }
}