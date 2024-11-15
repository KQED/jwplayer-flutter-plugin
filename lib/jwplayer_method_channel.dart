import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'jwplayer_platform_interface.dart';

/// An implementation of [JwplayerPlatform] that uses method channels.
class MethodChannelJwplayer extends JwplayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('org.kqed.jwplayer');

  @override
  Future<void> init(String licenseKey) async {
    final result = await methodChannel
        .invokeMethod('initializeJwPlayer', {"licenseKey": licenseKey});
    if (kDebugMode) {
      print(result);
    }
  }

  @override
  Future<void> play(
    String url,
    String? videoTitle,
    String? videoDescription,
    List<Caption>? captions,
  ) async {
    final result = await methodChannel.invokeMethod('play', {
      "url": url,
      "videoTitle": videoTitle,
      "videoDescription": videoDescription,
      "captions": convertCaptions(captions ?? []),
    });
    if (kDebugMode) {
      print(result);
    }
  }

  List<Map<String, dynamic>> convertCaptions(List<Caption> captions) {
    List<Map<String, dynamic>> captionsList =
        captions.map((caption) => caption.toMap()).toList();
    return captionsList;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
