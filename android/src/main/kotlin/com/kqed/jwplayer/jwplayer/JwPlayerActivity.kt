package com.kqed.jwplayer.jwplayer

import android.os.Bundle
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import com.jwplayer.pub.api.configuration.PlayerConfig
import com.jwplayer.pub.api.media.playlists.PlaylistItem
import com.jwplayer.pub.view.JWPlayerView
import com.jwplayer.pub.api.media.captions.Caption
import com.jwplayer.pub.api.media.captions.CaptionType

data class PlugInCaption(
    val url: String,
    val languageLabel: String
) {
    companion object {
        // Function to parse the input string and return an array of PlugInCaption objects
        fun fromMap(input: String): Array<PlugInCaption> {
            // Step 1: Extract languageLabel and URL into a map
            val regex = Regex("""languageLabel=(\w+),.*?url=([^\s,}]+)""")
            val mapList = mutableListOf<Map<String, String>>()

            regex.findAll(input).forEach { matchResult ->
                val languageLabel = matchResult.groupValues[1]
                val url = matchResult.groupValues[2]
                mapList.add(
                    mapOf(
                        "languageLabel" to languageLabel,
                        "url" to url
                    )
                )
            }

            // Step 2: Transform the map list into an array of PlugInCaption
            return mapList.map { map ->
                PlugInCaption(
                    url = map["url"] ?: "",
                    languageLabel = map["languageLabel"] ?: ""
                )
            }.toTypedArray()
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
            val plugInCaptions = PlugInCaption.fromMap(captionsString)
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