package com.kqed.jwplayer.jwplayer

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class JwplayerViewFactory(
    private val activityProvider: () -> android.app.Activity?
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<String?, Any?>
        return JwplayerPlatformView(context, viewId, creationParams, activityProvider)
    }
}
