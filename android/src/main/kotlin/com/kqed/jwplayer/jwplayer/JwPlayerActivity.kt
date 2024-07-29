package com.kqed.jwplayer.jwplayer

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.jwplayer.pub.api.configuration.PlayerConfig
import com.jwplayer.pub.api.media.playlists.PlaylistItem
import com.jwplayer.pub.view.JWPlayerView

class JwPlayerActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_jw_player)

        val view = findViewById<JWPlayerView>(R.id.jwPlayerView)
        val url = intent.getStringExtra("url")

        val playlistItem = PlaylistItem.Builder()
            .file(url)
            .build()
        val playlist: MutableList<PlaylistItem> = ArrayList()
        playlist.add(playlistItem)

        val config = PlayerConfig.Builder()
            .playlist(playlist)
            .build()

        view.getPlayer(this).setup(config)
    }
}