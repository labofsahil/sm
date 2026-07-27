package com.example.my_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private external fun initNdkContext(context: Any)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            initNdkContext(applicationContext)
        } catch (e: Throwable) {
            android.util.Log.e("MainActivity", "Failed to initialize ndk_context", e)
        }
    }
}

