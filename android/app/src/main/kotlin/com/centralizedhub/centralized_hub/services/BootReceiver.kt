package com.centralizedhub.centralized_hub.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * BroadcastReceiver that listens for BOOT_COMPLETED and MY_PACKAGE_REPLACED
 * to automatically restart TrackingForegroundService if tracking was enabled.
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
        private const val PREFS_NAME = "centralized_hub_prefs"
        private const val KEY_TRACKING_ENABLED = "tracking_enabled"
        private const val KEY_SAMPLE_INTERVAL = "sample_interval_ms"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_BOOT_COMPLETED || action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            Log.d(TAG, "Received action: $action")

            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val isTrackingEnabled = prefs.getBoolean(KEY_TRACKING_ENABLED, false)

            if (isTrackingEnabled) {
                val intervalMs = prefs.getInt(KEY_SAMPLE_INTERVAL, 30000)
                Log.d(TAG, "Restarting TrackingForegroundService with interval ${intervalMs}ms")

                val serviceIntent = Intent(context, TrackingForegroundService::class.java).apply {
                    putExtra("intervalMs", intervalMs)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
            } else {
                Log.d(TAG, "Tracking was not enabled, skipping service start")
            }
        }
    }
}
