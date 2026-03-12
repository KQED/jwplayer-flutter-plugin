import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jwplayer/jwplayer.dart';
import 'package:jwplayer/jwplayer_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pluginCallbacksChannelData = 'Unknown';
  final _pluginCallbacksChannel = const MethodChannel('org.kqed.jwplayer');

  final _jwplayerPlugin = Jwplayer();
  int? _embeddedViewId;
  bool _embeddedMuted = false;
  bool _showMethodChannelDemo = true;
  // License keys can be found at https://dashboard.jwplayer.com/p/<siteId>/players
  final iosLicenseKey = 'iosLicenseKey';
  final androidLicenseKey = 'androidKey';
  final videoUrlHls = 'https://cdn.jwplayer.com/manifests/sMsaZfMG.m3u8';
  final videoUrlMp4 =
      'https://content.jwplatform.com/videos/7WmvDLh5-hYAEJ9Gw.mp4';
  final List<Caption> captions = [
    Caption(
      url: 'https://content.jwplatform.com/tracks/kvtKkKSM.vtt',
      locale: 'en',
      languageLabel: 'English',
    ),
    Caption(
      url: 'https://content.jwplatform.com/tracks/kvtKkKSM.vtt',
      locale: 'es',
      languageLabel: 'Spanish',
    ),
  ];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    registerForCallbacks();

    if (Platform.isAndroid) {
      if (androidLicenseKey == 'androidKey') {
        throw Exception('Android license key is not set');
      }
    } else {
      if (iosLicenseKey == 'iosLicenseKey') {
        throw Exception('iOS license key is not set');
      }
    }
  }

  void registerForCallbacks() {
    _pluginCallbacksChannel.setMethodCallHandler(_callbackMethodCallHandler);
  }

  Future<void> _callbackMethodCallHandler(MethodCall call) async {
    switch (call.method) {
      default:
        Future.delayed(Duration.zero, () {
          final data =
              'Method Call Triggered: ${call.method} with arguments ${call.arguments}';
          log(data);
          setState(() {
            _pluginCallbacksChannelData = data;
          });
        });
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    final licenseKey = Platform.isAndroid ? androidLicenseKey : iosLicenseKey;
    try {
      await _jwplayerPlugin.init(licenseKey);
    } on PlatformException {
      if (kDebugMode) {
        print('error');
      }
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> _toggleEmbeddedMute() async {
    final viewId = _embeddedViewId;
    if (viewId == null) return;
    final newMuted = !_embeddedMuted;
    await setJwplayerViewMuted(viewId, newMuted);
    if (!mounted) return;
    setState(() {
      _embeddedMuted = newMuted;
    });
  }

  Future<void> _openFullScreenFromEmbedded() async {
    final viewId = _embeddedViewId;
    if (viewId == null) return;
    try {
      final position = await _jwplayerPlugin.getPosition(viewId);
      await _jwplayerPlugin.play(
        videoUrlHls,
        videoTitle: 'Example title',
        videoDescription: 'Example video description',
        captions: captions,
        startPosition: position,
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Error opening full-screen from embedded player: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('JWPlayer Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showMethodChannelDemo = true;
                        });
                      },
                      child: const Text('Show MethodChannel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showMethodChannelDemo = false;
                        });
                      },
                      child: const Text('Show PlatformView'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_showMethodChannelDemo) ...[
                const Text(
                  'MethodChannel full-screen player',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // When using .m3u8 (HLS) videos, Swift produces the following error:
                    // HALPlugIn.cpp:552 HALPlugIn::DeviceGetCurrentTime: got an error from the plug-in routine, Error: 1937010544 (stop)
                    // It doesn't appear to affect playback, so it should be ok, just calling
                    // it out here in case there are issues in the future
                    _jwplayerPlugin.play(
                      videoUrlHls,
                      videoTitle: 'Example title',
                      videoDescription: 'Example video description',
                      captions: captions,
                    );
                    // _jwplayerPlugin.play(videoUrlMp4);
                  },
                  child: const Text('Play full-screen video'),
                ),
                const SizedBox(height: 8),
                Text(
                  "Callback From SDK: $_pluginCallbacksChannelData END",
                ),
              ] else ...[
                const Text(
                  'Embedded JWPlayer (PlatformView)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: JwplayerWidget(
                      url: videoUrlHls,
                      videoTitle: 'Example title',
                      videoDescription: 'Embedded JWPlayer example',
                      captions: captions,
                      showControls: true,
                      onPlatformViewCreated: (viewId) {
                        setState(() {
                          _embeddedViewId = viewId;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _embeddedViewId == null
                            ? null
                            : _toggleEmbeddedMute,
                        child: Text(
                          _embeddedMuted ? 'Unmute embedded' : 'Mute embedded',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _embeddedViewId == null
                            ? null
                            : _openFullScreenFromEmbedded,
                        child: const Text('Open full-screen from embedded'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
