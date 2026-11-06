package com.centralizedhub.centralized_hub.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import com.centralizedhub.centralized_hub.MainActivity
import com.centralizedhub.centralized_hub.channels.TrackingServiceChannel

/**
 * Foreground service that:
 * 1. Polls UsageStatsManager every ~5s to detect foreground game changes
 * 2. Samples battery temperature + level at a configurable interval during active sessions
 * 3. Sends events to Flutter via TrackingServiceChannel event sink
 */
class TrackingForegroundService : Service() {

    companion object {
        const val TAG = "TrackingService"
        const val NOTIFICATION_CHANNEL_ID = "tracking_channel"
        const val NOTIFICATION_ID = 1001
        const val USAGE_POLL_INTERVAL_MS = 3000L

        @Volatile
        var isRunning = false

        @Volatile
        var sampleIntervalMs = 30000L

        val gamePackages = mutableSetOf<String>()

        fun updateGamePackages(context: Context, packages: Collection<String>) {
            gamePackages.addAll(packages)
            val prefs = context.getSharedPreferences("centralized_hub_prefs", Context.MODE_PRIVATE)
            prefs.edit().putStringSet("user_game_packages", HashSet(gamePackages)).apply()
            Log.d(TAG, "Updated game packages, total: ${gamePackages.size}")
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var currentForegroundPackage: String? = null
    private var isTrackedGameActive = false
    private var sessionStartTime: Long = 0
    private var hubForegroundStartTime: Long = 0L

    // Polling runnable for checking foreground app
    private val usagePollRunnable = object : Runnable {
        override fun run() {
            checkForegroundApp()
            handler.postDelayed(this, USAGE_POLL_INTERVAL_MS)
        }
    }

    // Sampling runnable for battery/temperature during active sessions
    private val sampleRunnable = object : Runnable {
        override fun run() {
            if (isTrackedGameActive) {
                takeSample()
                handler.postDelayed(this, sampleIntervalMs)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        loadGamePackages()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val intervalMs = intent?.getIntExtra("intervalMs", 30000) ?: 30000
        sampleIntervalMs = intervalMs.toLong()

        val packagesList = intent?.getStringArrayListExtra("gamePackages")
        if (packagesList != null && packagesList.isNotEmpty()) {
            gamePackages.addAll(packagesList)
        }

        val notification = buildNotification("Monitoring game sessions")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        isRunning = true

        // Start polling for foreground app changes
        handler.removeCallbacks(usagePollRunnable)
        handler.post(usagePollRunnable)

        Log.d(TAG, "Tracking service started with interval ${sampleIntervalMs}ms")
        return START_STICKY // Restart if killed
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        handler.removeCallbacks(usagePollRunnable)
        handler.removeCallbacks(sampleRunnable)

        // End active session if any
        if (isTrackedGameActive) {
            endSession()
        }

        Log.d(TAG, "Tracking service stopped")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Game Tracking",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors game sessions and device metrics"
                setShowBadge(false)
            }
            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(contentText: String): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
                .setContentTitle("Centralized Hub")
                .setContentText(contentText)
                .setSmallIcon(android.R.drawable.ic_menu_info_details)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("Centralized Hub")
                .setContentText(contentText)
                .setSmallIcon(android.R.drawable.ic_menu_info_details)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        }
    }

    private fun loadGamePackages() {
        try {
            val pm = packageManager
            val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
            for (app in apps) {
                if (isGameApp(app)) {
                    gamePackages.add(app.packageName)
                }
            }
            // Also load user-marked games from shared preferences
            val prefs = getSharedPreferences("centralized_hub_prefs", Context.MODE_PRIVATE)
            val userGames = prefs.getStringSet("user_game_packages", emptySet()) ?: emptySet()
            gamePackages.addAll(userGames)

            Log.d(TAG, "Loaded ${gamePackages.size} game packages")
        } catch (e: Exception) {
            Log.e(TAG, "Error loading game packages", e)
        }
    }

    private fun isGameApp(appInfo: ApplicationInfo): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (appInfo.category == ApplicationInfo.CATEGORY_GAME) return true
        }
        @Suppress("DEPRECATION")
        if (appInfo.flags and ApplicationInfo.FLAG_IS_GAME != 0) return true
        return false
    }

    private fun isGamePackage(pkg: String): Boolean {
        if (pkg == packageName) return false // Ignore Centralized Hub itself
        if (gamePackages.contains(pkg)) return true

        try {
            val appInfo = packageManager.getApplicationInfo(pkg, 0)
            if (isGameApp(appInfo)) {
                gamePackages.add(pkg)
                return true
            }
            // Heuristic detection for casual games (like Block Blast) without CATEGORY_GAME
            val lowerPkg = pkg.lowercase()
            val appLabel = packageManager.getApplicationLabel(appInfo).toString().lowercase()
            val keywords = listOf(
                "game", "blast", "block", "puzzle", "arcade", "racer",
                "craft", "simulator", "sudoku", "candy", "clash", "quest", "hero", "battle", "race", "runner", "match"
            )
            if (keywords.any { lowerPkg.contains(it) || appLabel.contains(it) }) {
                Log.d(TAG, "Heuristically detected game: $pkg ($appLabel)")
                gamePackages.add(pkg)
                return true
            }
        } catch (_: Exception) {}
        return false
    }

    private fun checkForegroundApp() {
        try {
            val usageStatsManager =
                getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val endTime = System.currentTimeMillis()
            val startTime = endTime - 15_000

            val events = usageStatsManager.queryEvents(startTime, endTime)
            val event = UsageEvents.Event()
            var lastForeground: String? = null

            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND ||
                    event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                    lastForeground = event.packageName
                }
            }

            // Fallback for Vivo / FuntouchOS if queryEvents omitted background events
            if (lastForeground == null) {
                try {
                    val stats = usageStatsManager.queryUsageStats(
                        UsageStatsManager.INTERVAL_DAILY,
                        endTime - 3600_000,
                        endTime
                    )
                    val mostRecent = stats.maxByOrNull { it.lastTimeUsed }
                    if (mostRecent != null && (endTime - mostRecent.lastTimeUsed) < 20_000) {
                        lastForeground = mostRecent.packageName
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "queryUsageStats fallback failed", e)
                }
            }

            if (lastForeground != null) {
                val isHub = (lastForeground == packageName)
                val isNewGame = !isHub && isGamePackage(lastForeground)

                if (isHub) {
                    // Centralized Hub is in foreground. If a game is active, keep session running
                    // so the user can inspect live metrics on the dashboard.
                    // If Hub remains open for > 90 seconds without returning to game, finalize session.
                    if (isTrackedGameActive) {
                        if (hubForegroundStartTime == 0L) {
                            hubForegroundStartTime = System.currentTimeMillis()
                        } else if (System.currentTimeMillis() - hubForegroundStartTime > 90_000) {
                            endSession()
                            hubForegroundStartTime = 0L
                        }
                    }
                } else {
                    hubForegroundStartTime = 0L
                    if (lastForeground != currentForegroundPackage) {
                        val previousPackage = currentForegroundPackage
                        currentForegroundPackage = lastForeground
                        val wasPreviousGame = previousPackage != null && isGamePackage(previousPackage)

                        // Previous game left foreground (user went home, or opened another app)
                        if (wasPreviousGame && isTrackedGameActive) {
                            endSession()
                        }

                        // New game entered foreground
                        if (isNewGame && !isTrackedGameActive) {
                            startSession(lastForeground)
                        }
                    } else if (isNewGame && !isTrackedGameActive) {
                        // Ongoing game that wasn't previously active
                        startSession(lastForeground)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking foreground app", e)
        }
    }

    private fun startSession(packageName: String) {
        isTrackedGameActive = true
        sessionStartTime = System.currentTimeMillis()

        val appName = try {
            val pm = packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            packageName
        }

        val batteryInfo = getBatteryInfo()

        val eventData = mapOf<String, Any?>(
            "event" to "session_start",
            "data" to mapOf(
                "packageName" to packageName,
                "appName" to appName,
                "isGame" to true,
                "batteryLevel" to batteryInfo["level"],
                "batteryTempC" to batteryInfo["temperatureC"],
                "isCharging" to batteryInfo["isCharging"]
            )
        )
        TrackingServiceChannel.sendEvent(eventData)

        // Take immediate initial sample so temperature is always present
        takeSample()

        // Update notification
        val nm = getSystemService(NotificationManager::class.java)
        nm.notify(NOTIFICATION_ID, buildNotification("Playing: $appName"))

        // Start periodic sampling
        handler.removeCallbacks(sampleRunnable)
        handler.postDelayed(sampleRunnable, sampleIntervalMs)

        Log.d(TAG, "Session started: $appName ($packageName)")
    }

    private fun endSession() {
        // Take final sample before closing
        takeSample()

        isTrackedGameActive = false
        handler.removeCallbacks(sampleRunnable)

        val batteryInfo = getBatteryInfo()

        val eventData = mapOf<String, Any?>(
            "event" to "session_end",
            "data" to mapOf(
                "batteryLevel" to batteryInfo["level"],
                "batteryTempC" to batteryInfo["temperatureC"],
                "isCharging" to batteryInfo["isCharging"]
            )
        )
        TrackingServiceChannel.sendEvent(eventData)

        // Restore notification
        val nm = getSystemService(NotificationManager::class.java)
        nm.notify(NOTIFICATION_ID, buildNotification("Monitoring game sessions"))

        Log.d(TAG, "Session ended")
    }

    private fun takeSample() {
        val batteryInfo = getBatteryInfo()
        val thermalStatus = getThermalStatus()

        val eventData = mapOf<String, Any?>(
            "event" to "sample",
            "data" to mapOf(
                "batteryLevel" to batteryInfo["level"],
                "batteryTempC" to batteryInfo["temperatureC"],
                "isCharging" to batteryInfo["isCharging"],
                "thermalStatus" to thermalStatus
            )
        )
        TrackingServiceChannel.sendEvent(eventData)
    }

    private fun getBatteryInfo(): Map<String, Any?> {
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus = registerReceiver(null, intentFilter)

        if (batteryStatus == null) {
            return mapOf("level" to 0, "temperatureC" to 0.0, "isCharging" to false)
        }

        val level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        val levelPercent = if (level >= 0 && scale > 0) (level * 100 / scale) else 0

        val tempTenths = batteryStatus.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0)
        val temperatureC = tempTenths / 10.0

        val status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
        val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                status == BatteryManager.BATTERY_STATUS_FULL

        return mapOf(
            "level" to levelPercent,
            "temperatureC" to temperatureC,
            "isCharging" to isCharging
        )
    }

    private fun getThermalStatus(): Int? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.currentThermalStatus
    }
}
