package com.mayegue.app;

import io.flutter.app.FlutterApplication;
import android.util.Log;

public class MainApplication extends FlutterApplication {
    private static final String TAG = "MainApplication";

    @Override
    public void onCreate() {
        super.onCreate();

        // Initialize Facebook SDK
        try {
            // Check if Facebook SDK is available
            Class<?> facebookSdkClass = Class.forName("com.facebook.FacebookSdk");
            // Initialize Facebook SDK
            java.lang.reflect.Method sdkInitialize = facebookSdkClass.getMethod("sdkInitialize", android.content.Context.class);
            sdkInitialize.invoke(null, getApplicationContext());

            // Set auto-logging of events
            java.lang.reflect.Method setAutoLogAppEventsEnabled = facebookSdkClass.getMethod("setAutoLogAppEventsEnabled", boolean.class);
            setAutoLogAppEventsEnabled.invoke(null, true);

            // Set advertiser ID collection
            java.lang.reflect.Method setAdvertiserIDCollectionEnabled = facebookSdkClass.getMethod("setAdvertiserIDCollectionEnabled", boolean.class);
            setAdvertiserIDCollectionEnabled.invoke(null, true);

            Log.d(TAG, "Facebook SDK initialized successfully");
        } catch (ClassNotFoundException e) {
            Log.w(TAG, "Facebook SDK not available, skipping initialization");
        } catch (Exception e) {
            Log.e(TAG, "Failed to initialize Facebook SDK", e);
        }
    }
}

