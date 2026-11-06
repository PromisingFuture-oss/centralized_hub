package com.centralizedhub.centralized_hub.channels

import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.centralizedhub.centralized_hub.services.TrackingForegroundService

class TrackingServiceChannel(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    private val methodChannel = MethodChannel(messenger, "com.centralizedhub/tracking_service")

    // Static event sink accessible by the foreground service
    companion object {
        private var eventSink: EventChannel.EventSink? = null
        private val eventChannel: EventChannel? = null

        fun sendEvent(data: Map<String, Any?>) {
            eventSink?.success(data)
        }
    }

    init {
        methodChannel.setMethodCallHandler(this)

        // Set up the event channel for tracking events
        val trackingEventChannel = EventChannel(messenger, "com.centralizedhub/tracking_events")
        trackingEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startService" -> {
                val intervalMs = call.argument<Int>("intervalMs") ?: 30000
                val packages = call.argument<List<String>>("gamePackages") ?: emptyList()
                startService(intervalMs, packages)
                result.success(true)
            }
            "stopService" -> {
                stopService()
                result.success(null)
            }
            "isRunning" -> {
                result.success(TrackingForegroundService.isRunning)
            }
            "updateInterval" -> {
                val intervalMs = call.argument<Int>("intervalMs") ?: 30000
                TrackingForegroundService.sampleIntervalMs = intervalMs.toLong()
                result.success(null)
            }
            "updateGamePackages" -> {
                val packages = call.argument<List<String>>("gamePackages") ?: emptyList()
                TrackingForegroundService.updateGamePackages(context, packages)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun startService(intervalMs: Int, gamePackages: List<String>) {
        val intent = Intent(context, TrackingForegroundService::class.java).apply {
            putExtra("intervalMs", intervalMs)
            putStringArrayListExtra("gamePackages", ArrayList(gamePackages))
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }

    private fun stopService() {
        val intent = Intent(context, TrackingForegroundService::class.java)
        context.stopService(intent)
    }
}
