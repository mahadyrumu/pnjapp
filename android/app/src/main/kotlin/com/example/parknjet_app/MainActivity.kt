package com.parknjet.dispatch

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/maps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openMap" -> {
                    val location1 = call.argument<String>("location1")
                    val location2 = call.argument<String>("location2")
                    if (location1 != null && location2 != null) {
                        openGoogleMap(location1, location2)
                        result.success(null)
                    } else {
                        result.error("ERROR", "Arguments are missing", null)
                    }
                }
                "openSingleMap" -> {
                    val location = call.argument<String>("location")
                    if (location != null) {
                        openSingleGoogleMap(location)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Location argument is missing", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openGoogleMap(location1: String, location2: String) {
        // Encode the location coordinates and names for URL
        val encodedLocation1 = Uri.encode("Park N Jet Lot-1, SeaTac Airport Parking ($location1)")
        val encodedLocation2 = Uri.encode("Park N Jet Lot-2, SeaTac Airport Parking ($location2)")
    
        // Create a URL for Google Maps with directions between the two locations
        val uri = Uri.parse("https://www.google.com/maps/dir/?api=1&origin=$encodedLocation1&destination=$encodedLocation2")
        val intent = Intent(Intent.ACTION_VIEW, uri)
        intent.setPackage("com.google.android.apps.maps")
    
        // Check if Google Maps app is available
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        } else {
            // Handle case when Google Maps app is not installed
            openGoogleMapsInBrowser(uri.toString())
        }
    }    
    

    private fun openSingleGoogleMap(location: String?) {
        if (location != null) {
            // Check the location coordinates and set the appropriate name
            val name = when (location) {
                "47.43914018881809, -122.32354565029163" -> "Park N Jet Lot-1, SeaTac Airport Parking"
                "47.47791718815681, -122.31643312461328" -> "Park N Jet Lot-2, SeaTac Airport Parking"
                else -> "Park N Jet, SeaTac Airport Parking" // Default name if location doesn't match
            }
    
            // Create a URL for Google Maps with the location and label
            val uri = Uri.parse("https://www.google.com/maps?q=$location($name)")
            val intent = Intent(Intent.ACTION_VIEW, uri)
            intent.setPackage("com.google.android.apps.maps")
    
            // Check if Google Maps app is available
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
            } else {
                // Handle the case where Google Maps app is not installed
                // You can show a message or fallback to another method
            }
        }
    }

    // Fallback function to open Google Maps in a browser if the app is not available
    private fun openGoogleMapsInBrowser(url: String) {
        val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        startActivity(browserIntent)
    }
}
