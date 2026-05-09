package com.loopify.loopify

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class LoopifyWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val streak = widgetData.getInt("streak", 0)
        val habitsCompleted = widgetData.getInt("habits_completed", 0)
        val quip = widgetData.getString("quip", "Let's build something! 🚀")
        val imageName = widgetData.getString("image", "1.png")

        val views = RemoteViews(context.packageName, R.layout.loopify_widget)

        // Set streak text
        views.setTextViewText(R.id.widget_streak, "🔥 $streak")

        // Set quip
        views.setTextViewText(R.id.widget_quip, quip)

        // Set image based on habits completed level
        val imageRes = when (imageName) {
            "1.png" -> R.drawable.widget_1
            "2.png" -> R.drawable.widget_2
            "3.png" -> R.drawable.widget_3
            else -> R.drawable.widget_1
        }
        views.setImageViewResource(R.id.widget_image, imageRes)

        // Add tap to open app
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
