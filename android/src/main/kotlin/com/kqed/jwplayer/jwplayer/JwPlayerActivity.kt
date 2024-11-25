package com.kqed.jwplayer.jwplayer

import android.os.Bundle
import android.view.MenuItem
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_jw_player)

        supportActionBar?.setHomeButtonEnabled(true)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowTitleEnabled(false)

        val view = findViewById<JWPlayerView>(R.id.jwPlayerView)
        val url = intent.getStringExtra("url")

        val captionTracks: ArrayList<Caption> = ArrayList();
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

        val playlistItem = PlaylistItem.Builder()
            .file(url)
            .tracks(captionTracks)
            .build()
        val playlist: MutableList<PlaylistItem> = ArrayList()
        playlist.add(playlistItem)

        val config = PlayerConfig.Builder()
            .playlist(playlist)
            .autostart(true)
            .build()

        view.getPlayer(this).setup(config)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            android.R.id.home -> finish()
        }
        return true
    }
}