package com.kqed.jwplayer.jwplayer

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.jwplayer.pub.api.license.LicenseUtil
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

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
  private var activityBinding: ActivityPluginBinding? = null
  private var pendingPlayResult: Result? = null
  private val fullScreenRequestCode = 9001

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, incomingChannelName)
    channel.setMethodCallHandler(this)
    callbackChannel = channel

    val viewFactory = JwplayerViewFactory { boundActivity }
    flutterPluginBinding.platformViewRegistry.registerViewFactory(
      "org.kqed.jwplayer/jwplayer_view",
      viewFactory
    )
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
          val captionsArg = "captions"
          val startPositionArg = "startPosition"

          val argumentData = call.arguments as? Map<*, *>
          val url = argumentData?.get(urlArg)
          val captions = argumentData?.get(captionsArg)
          val startPosition = (argumentData?.get(startPositionArg) as? Number)?.toDouble()

          val myIntent = Intent(boundActivity, JwPlayerActivity::class.java)
          myIntent.putExtra("url", url.toString())
          myIntent.putExtra("captions", captions.toString())
          startPosition?.let { myIntent.putExtra("startPosition", it) }

          val activity = boundActivity
          if (activity != null) {
            pendingPlayResult = result
            activity.startActivityForResult(myIntent, fullScreenRequestCode)
            callbackToFlutterApp(
              CallbackMethod.sdkPlayMethodCalled.methodKey,
              mapOf("videoUrl" to url.toString())
            )
          } else {
            result.success(-1.0)
          }
        }

        PluginMethods.GetPosition.value -> {
          val argumentData = call.arguments as? Map<*, *>
          val viewId = (argumentData?.get("viewId") as? Number)?.toInt()
          if (viewId != null) {
            val position = JwplayerViewRegistry.getPosition(viewId)
            result.success(position)
          } else {
            result.error("INVALID_ARGUMENT", "viewId required", null)
          }
        }

        PluginMethods.SeekTo.value -> {
          val argumentData = call.arguments as? Map<*, *>
          val viewId = (argumentData?.get("viewId") as? Number)?.toInt()
          val position = (argumentData?.get("position") as? Number)?.toDouble()
          if (viewId != null && position != null) {
            JwplayerViewRegistry.seekTo(viewId, position)
            result.success(null)
          } else {
            result.error("INVALID_ARGUMENT", "viewId and position required", null)
          }
        }

        PluginMethods.Resume.value -> {
          val argumentData = call.arguments as? Map<*, *>
          val viewId = (argumentData?.get("viewId") as? Number)?.toInt()
          if (viewId != null) {
            JwplayerViewRegistry.play(viewId)
            result.success(null)
          } else {
            result.error("INVALID_ARGUMENT", "viewId required", null)
          }
        }

        PluginMethods.SetMuted.value -> {
          val argumentData = call.arguments as? Map<*, *>
          val viewId = (argumentData?.get("viewId") as? Number)?.toInt()
          val muted = argumentData?.get("muted") as? Boolean
          if (viewId != null && muted != null) {
            JwplayerViewRegistry.setMuted(viewId, muted)
            result.success(null)
          } else {
            result.error("INVALID_ARGUMENT", "viewId and muted required", null)
          }
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
    activityBinding = binding
    binding.addActivityResultListener(activityResultListener)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    boundActivity = null
    activityBinding?.removeActivityResultListener(activityResultListener)
    activityBinding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    boundActivity = binding.activity
    activityBinding = binding
    binding.addActivityResultListener(activityResultListener)
  }

  override fun onDetachedFromActivity() {
    boundActivity = null
    activityBinding?.removeActivityResultListener(activityResultListener)
    activityBinding = null
  }

  private val activityResultListener = ActivityResultListener { requestCode, resultCode, data ->
    if (requestCode == fullScreenRequestCode) {
      val position = if (resultCode == Activity.RESULT_OK && data != null) {
        data.getDoubleExtra("position", 0.0)
      } else {
        -1.0
      }
      pendingPlayResult?.success(position)
      pendingPlayResult = null
      true
    } else {
      false
    }
  }

  private fun callbackToFlutterApp(method: String, arguments: Map<String, String>? = null) {
    callbackChannel.invokeMethod(method, arguments ?: emptyMap<String, String>())
  }
}