package org.sparcs.taxi_app

import io.flutter.embedding.android.FlutterActivity
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat


class MainActivity: FlutterActivity() {
    private val CHANNEL = "org.sparcs.taxi_app/taxi_only"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Flutter의 SafeArea가 이미 상태바/내비게이션바 여백을 주는데, WebView도 window insets를 받아
        // env(safe-area-inset-*)로 웹에 넘기면 여백이 이중으로 생긴다. WebView에는 빈 insets를 전달한다.
        window.decorView.viewTreeObserver.addOnGlobalLayoutListener {
            blockWebViewInsets(window.decorView)
        }
    }

    private fun blockWebViewInsets(view: View) {
        if (view !is ViewGroup) return
        for (i in 0 until view.childCount) {
            val child = view.getChildAt(i)
            if (child is WebView) {
                if (view.getTag(R.id.webview_insets_blocked) == null) {
                    view.setTag(R.id.webview_insets_blocked, true)
                    ViewCompat.setOnApplyWindowInsetsListener(view) { parent, _ ->
                        val empty = WindowInsetsCompat.Builder().build()
                        val group = parent as ViewGroup
                        for (j in 0 until group.childCount) {
                            ViewCompat.dispatchApplyWindowInsets(group.getChildAt(j), empty)
                        }
                        WindowInsetsCompat.CONSUMED
                    }
                    ViewCompat.requestApplyInsets(view)
                }
            } else {
                blockWebViewInsets(child)
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchURI") {
                try {
                    val intent = Intent.parseUri(call.arguments as String, Intent.URI_INTENT_SCHEME)

                    if (intent.resolveActivity(packageManager) != null) {
                        packageManager.getLaunchIntentForPackage(""+intent.getPackage())
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
