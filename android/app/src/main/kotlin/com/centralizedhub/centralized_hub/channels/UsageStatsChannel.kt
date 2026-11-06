package com.centralizedhub.centralized_hub.channels

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.provider.Settings
import android.util.Base64
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class UsageStatsChannel(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "com.centralizedhub/usage_stats")

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasPermission" -> result.success(hasUsageStatsPermission())
            "openPermissionSettings" -> {
                openUsageStatsSettings()
                result.success(null)
            }
            "getInstalledApps" -> {
                val gamesOnly = call.argument<Boolean>("gamesOnly") ?: false
                Thread {
                    val apps = getInstalledApps(gamesOnly)
                    Handler(Looper.getMainLooper()).post {
                        result.success(apps)
                    }
                }.start()
            }
            "getUsageEvents" -> {
                val startTime = call.argument<Long>("startTime") ?: 0L
                val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                result.success(getUsageEvents(startTime, endTime))
            }
            "getCurrentForegroundPackage" -> {
                result.success(getCurrentForegroundPackage())
            }
            "launchApp" -> {
                val packageName = call.argument<String>("packageName")
                if (packageName != null) {
                    val launched = launchApp(packageName)
                    result.success(launched)
                } else {
                    result.error("INVALID_ARGUMENT", "Package name cannot be null", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageStatsSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    private fun getInstalledApps(gamesOnly: Boolean): List<Map<String, Any?>> {
        val pm = context.packageManager
        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val result = mutableListOf<Map<String, Any?>>()

        for (app in apps) {
            // Skip system apps without a launcher icon
            val launchIntent = pm.getLaunchIntentForPackage(app.packageName)
            if (launchIntent == null) continue

            val isGame = isGameApp(app)
            val isMedia = isMediaApp(app)
            if (gamesOnly && !isGame) continue

            val appName = pm.getApplicationLabel(app).toString()
            val iconBase64 = try {
                val drawable = pm.getApplicationIcon(app.packageName)
                drawableToBase64(drawable)
            } catch (e: Exception) {
                null
            }

            result.add(
                mapOf(
                    "packageName" to app.packageName,
                    "appName" to appName,
                    "isGame" to isGame,
                    "isMedia" to isMedia,
                    "iconBase64" to iconBase64
                )
            )
        }

        return result.sortedBy { it["appName"] as String }
    }

    private fun isGameApp(appInfo: ApplicationInfo): Boolean {
        // API 26+: check category
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (appInfo.category == ApplicationInfo.CATEGORY_GAME) return true
        }
        // Fallback: check flags (deprecated but still works)
        @Suppress("DEPRECATION")
        if (appInfo.flags and ApplicationInfo.FLAG_IS_GAME != 0) return true

        // Keyword heuristic for casual games like Block Blast that lack CATEGORY_GAME
        val pkg = appInfo.packageName.lowercase()
        val label = try {
            context.packageManager.getApplicationLabel(appInfo).toString().lowercase()
        } catch (_: Exception) { "" }
        val keywords = listOf(
            "game", "blast", "block", "puzzle", "arcade", "racer",
            "craft", "simulator", "sudoku", "candy", "clash", "quest", "hero", "battle"
        )
        return keywords.any { pkg.contains(it) || label.contains(it) }
    }

    private fun isMediaApp(appInfo: ApplicationInfo): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (appInfo.category == ApplicationInfo.CATEGORY_VIDEO ||
                appInfo.category == ApplicationInfo.CATEGORY_AUDIO
            ) {
                return true
            }
        }

        val pkg = appInfo.packageName.lowercase()
        val label = try {
            context.packageManager.getApplicationLabel(appInfo).toString().lowercase()
        } catch (_: Exception) { "" }

        val keywords = listOf(
            "youtube", "vanced", "revanced", "newpipe", "netflix", "twitch",
            "crunchyroll", "disney", "primevideo", "hulu", "bilibili", "aniwave",
            "kick", "plex", "jellyfin", "vlc", "mxplayer", "stream", "video",
            "cinema", "tv", "dailymotion", "mihon", "tachiyomi", "webtoon",
            "reader", "comic", "manga", "tapas", "lezhin", "shonen", "viz",
            "kindle", "kobo", "moonreader", "spotify", "soundcloud", "music",
            "podcast", "deezer", "tidal", "audible", "pocketcasts", "radio"
        )
        return keywords.any { pkg.contains(it) || label.contains(it) }
    }

    private fun getUsageEvents(startTime: Long, endTime: Long): List<Map<String, Any>> {
        val usageStatsManager =
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usageStatsManager.queryEvents(startTime, endTime)
        val result = mutableListOf<Map<String, Any>>()
        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND ||
                event.eventType == UsageEvents.Event.MOVE_TO_BACKGROUND
            ) {
                result.add(
                    mapOf(
                        "eventType" to event.eventType,
                        "packageName" to event.packageName,
                        "timestamp" to event.timeStamp
                    )
                )
            }
        }

        return result
    }

    private fun getCurrentForegroundPackage(): String? {
        val usageStatsManager =
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 10_000 // Last 10 seconds

        val events = usageStatsManager.queryEvents(startTime, endTime)
        val event = UsageEvents.Event()
        var lastForegroundPackage: String? = null

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                lastForegroundPackage = event.packageName
            }
        }

        if (lastForegroundPackage == null) {
            try {
                val stats = usageStatsManager.queryUsageStats(
                    UsageStatsManager.INTERVAL_DAILY,
                    endTime - 3600_000,
                    endTime
                )
                val mostRecent = stats.maxByOrNull { it.lastTimeUsed }
                if (mostRecent != null && (endTime - mostRecent.lastTimeUsed) < 20_000) {
                    lastForegroundPackage = mostRecent.packageName
                }
            } catch (_: Exception) {}
        }

        return lastForegroundPackage
    }

    private fun drawableToBase64(drawable: Drawable): String {
        val bitmap = drawableToBitmap(drawable)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        val targetSize = 48
        if (drawable is BitmapDrawable && drawable.bitmap != null) {
            val original = drawable.bitmap
            if (original.width <= 64 && original.height <= 64) {
                return original
            }
            return Bitmap.createScaledBitmap(original, targetSize, targetSize, true)
        }
        val bitmap = Bitmap.createBitmap(targetSize, targetSize, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    private fun launchApp(packageName: String): Boolean {
        return try {
            val intent = context.packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                true
            } else {
                false
            }
        } catch (_: Exception) {
            false
        }
    }
}
