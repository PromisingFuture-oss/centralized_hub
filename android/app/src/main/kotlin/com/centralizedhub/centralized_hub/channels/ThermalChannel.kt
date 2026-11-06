package com.centralizedhub.centralized_hub.channels

import android.content.Context
import android.os.Build
import android.os.PowerManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ThermalChannel(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "com.centralizedhub/thermal")

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isThermalApiAvailable" -> {
                result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
            }
            "getCurrentThermalStatus" -> {
                result.success(getThermalStatus())
            }
            else -> result.notImplemented()
        }
    }

    private fun getThermalStatus(): Int? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.currentThermalStatus
    }
}
