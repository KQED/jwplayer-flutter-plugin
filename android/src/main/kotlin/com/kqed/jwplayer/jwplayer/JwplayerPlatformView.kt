package com.kqed.jwplayer.jwplayer

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.jwplayer.pub.api.configuration.PlayerConfig
import com.jwplayer.pub.api.media.captions.Caption
import com.jwplayer.pub.api.media.captions.CaptionType
import com.jwplayer.pub.api.media.playlists.PlaylistItem
import com.jwplayer.pub.view.JWPlayerView
import io.flutter.plugin.platform.PlatformView

class JwplayerPlatformView(
    private val context: Context,
    private val viewId: Int,
    creationParams: Map<String?, Any?>?,
    private val activityProvider: () -> android.app.Activity?
) : PlatformView {

    private val containerView: FrameLayout = FrameLayout(context)
    private var playerView: JWPlayerView? = null

    init {
        val url = creationParams?.get("url") as? String ?: return
        val captionsList = creationParams["captions"] as? List<*>
        val muted = when (val m = creationParams?.get("muted")) {
            is Boolean -> m
            is Number -> m.toInt() != 0
            else -> false
        }

        val playerView = JWPlayerView(context)
        playerView.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        containerView.addView(playerView)
        this.playerView = playerView

        val captionTracks = ArrayList<Caption>()
        if (captionsList != null) {
            for (item in captionsList) {
                val captionMap = item as? Map<*, *> ?: continue
                val urlStr = captionMap["url"] as? String ?: continue
                val languageLabel = captionMap["languageLabel"] as? String ?: continue
                captionTracks.add(
                    Caption.Builder()
                        .file(urlStr)
                        .label(languageLabel)
                        .kind(CaptionType.CAPTIONS)
                        .build()
                )
            }
        }

        val playlistItem = PlaylistItem.Builder()
            .file(url)
            .tracks(captionTracks)
            .build()
        val playlist = mutableListOf(playlistItem)

        val config = PlayerConfig.Builder()
            .playlist(playlist)
            .autostart(true)
            .mute(muted)
            .build()

        val activity = activityProvider()
        if (activity != null) {
            val player = playerView.getPlayer(activity)
            player.setup(config)
        }

        JwplayerViewRegistry.register(viewId, this)
    }

    fun setMuted(muted: Boolean) {
        playerView?.let { view ->
            activityProvider()?.let { activity ->
                view.getPlayer(activity).setMute(muted)
            }
        }
    }

    override fun getView(): View = containerView

    override fun dispose() {
        JwplayerViewRegistry.unregister(viewId)
        playerView?.let { view ->
            try {
                activityProvider()?.let { activity ->
                    view.getPlayer(activity).stop()
                }
            } catch (e: Exception) {
                // Ignore cleanup errors
            }
            playerView = null
        }
    }
}
