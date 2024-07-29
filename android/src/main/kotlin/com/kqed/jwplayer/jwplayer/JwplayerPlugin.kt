package com.kqed.jwplayer.jwplayer

import android.R.attr.value
import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** JwplayerPlugin */
class JwplayerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var callbackChannel : MethodChannel
  private var boundActivity: Activity? = null
  private val incomingChannelName = "org.kqed.jwplayer"

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, incomingChannelName)
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    try  {
      when (call.method) {
        PluginMethods.Init.value -> {
          result.success("jwplayer init")
        }

        PluginMethods.Play.value -> {
          result.success("jwplayer play")
          val myIntent = Intent(boundActivity, JwPlayerActivity::class.java)
          myIntent.putExtra("key", value) //Optional parameters
          boundActivity?.startActivity(myIntent)
        }

        "getPlatformVersion" -> {
          result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
      }
    } catch (error: Exception) {
      result.error(
        "MethodNotSupported",
        "MethodCall of (${call.method}) is not supported.",
        null
      )
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    boundActivity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    boundActivity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    boundActivity = binding.activity
  }

  override fun onDetachedFromActivity() {
    boundActivity = null
  }
}