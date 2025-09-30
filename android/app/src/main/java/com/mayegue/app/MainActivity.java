package com.mayegue.app;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(android.os.Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Initialize Facebook SDK if available
        try {
            Class.forName("com.facebook.FacebookSdk");
            // Facebook SDK is available, initialize it
            android.util.Log.d("MainActivity", "Facebook SDK is available");
        } catch (ClassNotFoundException e) {
            // Facebook SDK is not available, skip initialization
            android.util.Log.d("MainActivity", "Facebook SDK not available, skipping initialization");
        } catch (Exception e) {
            // Log error but don't crash the app
            android.util.Log.e("MainActivity", "Facebook SDK initialization failed", e);
        }
    }
}
