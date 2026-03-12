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

    fun getPosition(viewId: Int): Double = views[viewId]?.getPosition() ?: -1.0

    fun seekTo(viewId: Int, position: Double) {
        views[viewId]?.seekTo(position)
    }

    fun play(viewId: Int) {
        views[viewId]?.play()
    }
}
