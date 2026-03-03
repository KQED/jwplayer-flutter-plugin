package com.kqed.jwplayer.jwplayer

import java.util.concurrent.ConcurrentHashMap

object JwplayerViewRegistry {
    private val views = ConcurrentHashMap<Int, JwplayerPlatformView>()

    fun register(viewId: Int, view: JwplayerPlatformView) {
        views[viewId] = view
    }

    fun unregister(viewId: Int) {
        views.remove(viewId)
    }

    fun setMuted(viewId: Int, muted: Boolean) {
        views[viewId]?.setMuted(muted)
    }
}
