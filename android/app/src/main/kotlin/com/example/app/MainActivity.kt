
package com.example.app

import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        requestHighestRefreshRate()
    }

    private fun requestHighestRefreshRate() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return
        }

        val display = windowManager.defaultDisplay
        val supportedModes = display.supportedModes

        val maxRefreshRate = supportedModes
            .maxOfOrNull { it.refreshRate } ?: 60f

        window.attributes = window.attributes.apply {
            preferredRefreshRate = maxRefreshRate
        }

        Log.d(
            "GameVaultRefresh",
            "Requested maximum refresh rate: $maxRefreshRate Hz"
        )
    }
}
