package org.sparcs.taxi_app

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "org.sparcs.taxi_app"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchURI") {
                try {
                    val intent = Intent.parseUri(call.arguments as String, Intent.URI_INTENT_SCHEME)

                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        Log.d(TAG, "Intent launched!")
                        result.success("Intent launched!")
                        return;
                    }
                    
                    val fallbackUrl = intent.getStringExtra("browser_fallback_url")
                    if(fallbackUrl != null){
                        result.error("UNAVAILABLE", "No activity found to handle intent", fallbackUrl)
                    } else{
                        result.error("UNAVAILABLE", "No activity found to handle intent", null)
                    }

                } catch (e: URISyntaxException) {
                    Log.e(TAG, "URISyntaxException: $e")
                    result.error("URISyntaxException", "URISyntaxException: $e", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
