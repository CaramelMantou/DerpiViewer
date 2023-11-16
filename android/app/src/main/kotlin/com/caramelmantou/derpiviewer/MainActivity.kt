package com.caramelmantou.derpiviewer

import android.os.Environment
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channelPath = "${BuildConfig.APPLICATION_ID}/path"
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelPath
        ).setMethodCallHandler { call, result ->
            if (call.method == "getPictures") {
                result.success(downloadPath.absolutePath)
                }
            else if(call.method =="getTemp"){
                result.success(tempPath.absolutePath)
            }
            else{
                result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private val downloadPath get() =
        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
    
    @Suppress("DEPRECATION")
    private val tempPath get() =
        this@MainActivity.getCacheDir()
}
