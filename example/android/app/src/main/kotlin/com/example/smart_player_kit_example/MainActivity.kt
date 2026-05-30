package com.example.smart_player_kit_example

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "smart_player_kit/pip"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isSupported" -> {
                    result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                }
                "enterPip" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        try {
                            val ratioX = call.argument<Double>("aspectRatioX")?.toInt() ?: 16
                            val ratioY = call.argument<Double>("aspectRatioY")?.toInt() ?: 9

                            val builder = PictureInPictureParams.Builder()
                                .setAspectRatio(Rational(ratioX, ratioY))

                            // ✅ Android 12+ — auto enter + seamless transition
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                builder.setAutoEnterEnabled(true)
                                builder.setSeamlessResizeEnabled(true)
                            }

                            enterPictureInPictureMode(builder.build())
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("PIP_ERROR", e.message, null)
                        }
                    } else {
                        result.error("UNSUPPORTED", "PiP requires Android 8.0+", null)
                    }
                }
                "exitPip" -> {
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // ✅ PiP mode change hone par Flutter ko notify karo
    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        methodChannel?.invokeMethod("pipModeChanged", isInPictureInPictureMode)
    }
}