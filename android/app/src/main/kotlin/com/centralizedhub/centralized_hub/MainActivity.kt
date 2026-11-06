package com.centralizedhub.centralized_hub

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.centralizedhub.centralized_hub.channels.UsageStatsChannel
import com.centralizedhub.centralized_hub.channels.BatteryChannel
import com.centralizedhub.centralized_hub.channels.ThermalChannel
import com.centralizedhub.centralized_hub.channels.PermissionChannel
import com.centralizedhub.centralized_hub.channels.TrackingServiceChannel

class MainActivity : FlutterActivity() {

    private lateinit var usageStatsChannel: UsageStatsChannel
    private lateinit var batteryChannel: BatteryChannel
    private lateinit var thermalChannel: ThermalChannel
    private lateinit var permissionChannel: PermissionChannel
    private lateinit var trackingServiceChannel: TrackingServiceChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        usageStatsChannel = UsageStatsChannel(this, messenger)
        batteryChannel = BatteryChannel(this, messenger)
        thermalChannel = ThermalChannel(this, messenger)
        permissionChannel = PermissionChannel(this, messenger)
        trackingServiceChannel = TrackingServiceChannel(this, messenger)
    }

    override fun onDestroy() {
        super.onDestroy()
        batteryChannel.dispose()
    }
}
