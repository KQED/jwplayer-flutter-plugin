package com.kqed.jwplayer.jwplayer

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.jwplayer.pub.api.configuration.PlayerConfig
import com.jwplayer.pub.api.license.LicenseUtil
import com.jwplayer.pub.api.media.playlists.PlaylistItem
import com.jwplayer.pub.view.JWPlayerView

class JwPlayerActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_jw_player)
        LicenseUtil().setLicenseKey(this, "ADD_LICENSE_KEY")

        val view = findViewById<JWPlayerView>(R.id.jwPlayerView)

        val playlistItem = PlaylistItem.Builder()
            .file("https://content.jwplatform.com/videos/7WmvDLh5-hYAEJ9Gw.mp4")
            .build()
        val playlist: MutableList<PlaylistItem> = ArrayList()
        playlist.add(playlistItem)

        val config = PlayerConfig.Builder()
            .playlist(playlist)
            .build()

        view.getPlayer(this).setup(config)
    }
}