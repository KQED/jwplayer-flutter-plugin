package com.kqed.jwplayer.jwplayer

import android.os.Bundle
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import com.jwplayer.pub.api.configuration.PlayerConfig
import com.jwplayer.pub.api.media.playlists.PlaylistItem
import com.jwplayer.pub.view.JWPlayerView
import com.jwplayer.pub.api.media.captions.Caption
import com.jwplayer.pub.api.media.captions.CaptionType

class JwPlayerActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_jw_player)

        supportActionBar?.setHomeButtonEnabled(true)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowTitleEnabled(false)

        val view = findViewById<JWPlayerView>(R.id.jwPlayerView)
        val url = intent.getStringExtra("url")
        val captionUrl = intent.getStringExtra("captionUrl")
        val captionLocale = intent.getStringExtra("captionLocale")
        val captionLanguageLabel = intent.getStringExtra("captionLanguageLabel")

        val captionTracks: ArrayList<Caption> = ArrayList();

        val captionEn: Caption = Caption.Builder()
            .file(captionUrl)
            .label(captionLanguageLabel)
            .kind(CaptionType.CAPTIONS)
            .isDefault(true)
            .build();
            
        captionTracks.add(captionEn);

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