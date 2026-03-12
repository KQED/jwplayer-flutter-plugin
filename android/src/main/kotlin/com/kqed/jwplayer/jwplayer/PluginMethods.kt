package com.kqed.jwplayer.jwplayer

enum class PluginMethods(val value: String) {
    Init("initializeJwPlayer"),
    Play("play"),
    SetMuted("setMuted"),
    GetPosition("getPosition"),
    SeekTo("seekTo"),
    Resume("resume");
}