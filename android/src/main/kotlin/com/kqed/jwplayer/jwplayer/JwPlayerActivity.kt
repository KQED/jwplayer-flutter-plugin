package com.kqed.jwplayer.jwplayer

import android.content.Intent
import android.os.Bundle
import android.view.MenuItem
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import com.jwplayer.pub.api.configuration.PlayerConfig
import com.jwplayer.pub.api.media.captions.Caption
import com.jwplayer.pub.api.media.captions.CaptionType
import com.jwplayer.pub.api.media.playlists.PlaylistItem
import com.jwplayer.pub.view.JWPlayerView

data class PlugInCaption(
    val url: String,
    val languageLabel: String
) {
    companion object {
        fun fromStringList(input: String): List<PlugInCaption> {
            if (input == "[]") {
                return emptyList<PlugInCaption>()
            }
            val listOfMaps = input
                .removeSurrounding("[", "]")
                .split("}, {") // Splits each map
                .map { mapString ->
                    mapString
                        .removeSurrounding("{", "}") // Remove curly braces for each map
                        .split(", ")
                        .associate { entry ->
                            val (key, value) = entry.split("=")
                            key.replace("{", "") to value
                        }
                }
            val captions = mutableListOf<PlugInCaption>()

            listOfMaps.map { eachMap ->
                eachMap["languageLabel"]?.let { label ->
                    eachMap["url"]?.let { url ->
                        captions.add(PlugInCaption(url, label))
                    }
                }
            }.toList()

            return captions
        }
    }
}

class JwPlayerActivity : AppCompatActivity() {

    private lateinit var playerView: JWPlayerView
    private val startPosition: Double by lazy {
        intent.getDoubleExtra("startPosition", 0.0)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_jw_player)

        supportActionBar?.setHomeButtonEnabled(true)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowTitleEnabled(false)

        playerView = findViewById(R.id.jwPlayerView)
        val url = intent.getStringExtra("url")

        val captionTracks: ArrayList<Caption> = ArrayList()
        val captionsString = intent.getStringExtra("captions")

        if (captionsString != null) {
            val plugInCaptions = PlugInCaption.fromStringList(captionsString)

            plugInCaptions.forEach { caption ->
                captionTracks.add(Caption.Builder()
                    .file(caption.url)
                    .label(caption.languageLabel)
                    .kind(CaptionType.CAPTIONS)
                    .build()
                )
            }
        }

        val playlistItemBuilder = PlaylistItem.Builder()
            .file(url)
            .tracks(captionTracks)
        if (startPosition > 0) {
            playlistItemBuilder.startTime(startPosition)
        }
        val playlistItem = playlistItemBuilder.build()
        val playlist: MutableList<PlaylistItem> = ArrayList()
        playlist.add(playlistItem)

        val config = PlayerConfig.Builder()
            .playlist(playlist)
            .autostart(true)
            .build()

        playerView.getPlayer(this).setup(config)

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                finishWithPosition()
            }
        })
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            android.R.id.home -> finishWithPosition()
        }
        return true
    }

    private fun finishWithPosition() {
        val position = try {
            playerView.getPlayer(this).getPosition()
        } catch (e: Exception) {
            0.0
        }
        val resultIntent = Intent().putExtra("position", position)
        setResult(RESULT_OK, resultIntent)
        finish()
    }
}