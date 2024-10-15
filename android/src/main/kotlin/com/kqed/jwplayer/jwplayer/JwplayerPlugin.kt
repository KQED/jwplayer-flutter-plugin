package com.kqed.jwplayer.jwplayer

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.jwplayer.pub.api.license.LicenseUtil
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
  private val tag = "JwPlayerPlugin"
  private lateinit var channel : MethodChannel
  private lateinit var callbackChannel : MethodChannel
  private var boundActivity: Activity? = null
  private val incomingChannelName = "org.kqed.jwplayer"

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, incomingChannelName)
    channel.setMethodCallHandler(this)
    callbackChannel = channel
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    try  {
      when (call.method) {
        PluginMethods.Init.value -> {
          val licenseKeyArg = "licenseKey"

          val argumentData = call.arguments as? Map<*, *>
          val licenseKey = argumentData?.get(licenseKeyArg)
          LicenseUtil().setLicenseKey(boundActivity, licenseKey.toString())
          callbackToFlutterApp(CallbackMethod.sdkLicenseKeySetSuccess.methodKey)
          result.success("jwplayer init")
        }

        PluginMethods.Play.value -> {
          val urlArg = "url"
          val captionUrlArg = "captionUrl"
          val captionLocaleArg = "captionLocale"
          val captionLanguageLabelArg = "captionLanguageLabel"

          val argumentData = call.arguments as? Map<*, *>

          val url = argumentData?.get(urlArg)
          val captionUrl = argumentData?.get(captionUrlArg)
          val captionLocale = argumentData?.get(captionLocaleArg)
          val captionLanguageLabel = argumentData?.get(captionLanguageLabelArg)

          val myIntent = Intent(boundActivity, JwPlayerActivity::class.java)
          myIntent.putExtra("url", url.toString())
          myIntent.putExtra("captionUrl", captionUrl.toString())
          myIntent.putExtra("captionLocale", captionLocale.toString())
          myIntent.putExtra("captionLanguageLabel", captionLanguageLabel.toString())

          boundActivity?.startActivity(myIntent)
          callbackToFlutterApp(
            CallbackMethod.sdkPlayMethodCalled.methodKey,
            mapOf("videoUrl" to url.toString())
          )
        }

        else -> {
          callbackToFlutterApp(
            CallbackMethod.sdkUnknownMethodError.methodKey,
            mapOf("method" to call.method)
          )
        }
      }
    } catch (error: Exception) {
      result.error(
        "UnknownException",
        error.message,
        error
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

  private fun callbackToFlutterApp(method: String, arguments: Map<String, String>? = null) {
    callbackChannel.invokeMethod(method, arguments ?: emptyMap<String, String>())
  }
}