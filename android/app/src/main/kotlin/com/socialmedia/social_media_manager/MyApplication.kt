package com.socialmedia.social_media_manager

import io.flutter.app.FlutterApplication
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger

class MyApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()

        // Initialize Facebook SDK
        FacebookSdk.sdkInitialize(applicationContext)
        AppEventsLogger.activateApp(this)
    }
}
