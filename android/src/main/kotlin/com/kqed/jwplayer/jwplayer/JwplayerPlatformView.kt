package com.kqed.jwplayer.jwplayer

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import androidx.appcompat.view.ContextThemeWrapper
import androidx.lifecycle.LifecycleOwner
import com.jwplayer.pub.api.configuration.PlayerConfig
import com.jwplayer.pub.api.configuration.UiConfig
import com.jwplayer.pub.api.events.CompleteEvent
import com.jwplayer.pub.api.events.EventType
import com.jwplayer.pub.api.events.listeners.VideoPlayerEvents
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
    private val shouldLoop: Boolean

    init {
        val url = creationParams?.get("url") as? String
        val captionsList = creationParams?.get("captions") as? List<*>
        val muted = when (val m = creationParams?.get("muted")) {
            is Boolean -> m
            is Number -> m.toInt() != 0
            else -> false
        }
        val startPosition = (creationParams?.get("startPosition") as? Number)?.toDouble()
        val showControls = creationParams?.get("showControls") as? Boolean ?: false
        shouldLoop = creationParams?.get("loop") as? Boolean ?: false

        if (url != null) {
            val activity = activityProvider()
            val themedContext = activity?.let {
                ContextThemeWrapper(it, androidx.appcompat.R.style.Theme_AppCompat_Light_NoActionBar)
            } ?: ContextThemeWrapper(context, androidx.appcompat.R.style.Theme_AppCompat_Light_NoActionBar)
            val view = JWPlayerView(themedContext)
            view.layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            containerView.addView(view)
            this.playerView = view

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

            val playlistItemBuilder = PlaylistItem.Builder()
                .file(url)
                .tracks(captionTracks)
            val playlistItem = if (startPosition != null && startPosition > 0) {
                playlistItemBuilder.startTime(startPosition).build()
            } else {
                playlistItemBuilder.build()
            }
            val playlist = mutableListOf(playlistItem)

            val uiConfig = if (showControls) {
                UiConfig.Builder().build()
            } else {
                UiConfig.Builder().hideAllControls().build()
            }
            val config = PlayerConfig.Builder()
                .playlist(playlist)
                .autostart(true)
                .mute(muted)
                .uiConfig(uiConfig)
                .build()

            val lifecycleOwner = activity as? LifecycleOwner
            if (lifecycleOwner != null) {
                val player = view.getPlayer(lifecycleOwner)
                player.setup(config)

                if (shouldLoop) {
                    player.addListener(
                        EventType.COMPLETE,
                        object : VideoPlayerEvents.OnCompleteListener {
                            override fun onComplete(completeEvent: CompleteEvent) {
                                player.seek(0.0)
                                player.play()
                            }
                        },
                    )
                }
            }
        }

        JwplayerViewRegistry.register(viewId, this)
    }

    fun setMuted(muted: Boolean) {
        playerView?.let { view ->
            val lifecycleOwner = activityProvider() as? LifecycleOwner
            if (lifecycleOwner != null) {
                view.getPlayer(lifecycleOwner).setMute(muted)
            }
        }
    }

    fun getPosition(): Double {
        return playerView?.let { view ->
            val lifecycleOwner = activityProvider() as? LifecycleOwner
            if (lifecycleOwner != null) {
                view.getPlayer(lifecycleOwner).getPosition()
            } else -1.0
        } ?: -1.0
    }

    fun seekTo(position: Double) {
        playerView?.let { view ->
            val lifecycleOwner = activityProvider() as? LifecycleOwner
            if (lifecycleOwner != null) {
                view.getPlayer(lifecycleOwner).seek(position)
            }
        }
    }

    fun play() {
        playerView?.let { view ->
            val lifecycleOwner = activityProvider() as? LifecycleOwner
            if (lifecycleOwner != null) {
                view.getPlayer(lifecycleOwner).play()
            }
        }
    }

    override fun getView(): View = containerView

    override fun dispose() {
        JwplayerViewRegistry.unregister(viewId)
        playerView?.let { view ->
            try {
                val lifecycleOwner = activityProvider() as? LifecycleOwner
                if (lifecycleOwner != null) {
                    view.getPlayer(lifecycleOwner).stop()
                }
            } catch (e: Exception) {
                // Ignore cleanup errors
            }
            playerView = null
        }
    }
}
