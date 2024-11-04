import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jwplayer/jwplayer.dart';

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
  final iosLicenseKey = 'iosLicenseKey';
  final androidLicenseKey = 'androidLicenseKey';
  final videoUrlHls = 'https://cdn.jwplayer.com/manifests/t6r9FzpF.m3u8';
  final videoUrlMp4 =
      'https://content.jwplatform.com/videos/7WmvDLh5-hYAEJ9Gw.mp4';
  final captionUrl = 'https://content.jwplatform.com/tracks/kvtKkKSM.vtt';
  final captionLocale = 'en';
  final captionLanguageLabel = 'English';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    registerForCallbacks();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('JWPlayer Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                const Text('JWPlayer'),
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
                      captionUrl: captionUrl,
                      captionLocale: captionLocale,
                      captionLanguageLabel: captionLanguageLabel,
                    );
                    // _jwplayerPlugin.play(videoUrlMp4);
                  },
                  child: const Text('Play video'),
                ),
                const SizedBox(height: 16),
                Text(
                  "Callback From SDK: $_pluginCallbacksChannelData END",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
