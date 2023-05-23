package org.sparcs.taxi_app

import io.flutter.embedding.android.FlutterActivity
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull


class MainActivity: FlutterActivity() {
    private val CHANNEL = "org.sparcs.taxi_app/taxi_only"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchURI") {
                try {
                    val intent = Intent.parseUri(call.arguments as String, Intent.URI_INTENT_SCHEME)

                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        result.success(null)
                    } else {
                    
                    val fallbackUrl = intent.getStringExtra("browser_fallback_url")
                    if(fallbackUrl != null){
                        result.success(fallbackUrl)
                    } else{
                        result.error("UNAVAILABLE", "No activity found to handle intent", null)
                    }
                }

                } catch (e: Exception) {
                    result.error("URISyntaxException", "URISyntaxException: $e", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
