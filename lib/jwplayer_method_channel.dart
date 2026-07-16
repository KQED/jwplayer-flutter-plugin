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
  Future<double?> play(
    String url, {
    String? videoTitle,
    String? videoDescription,
    List<Caption>? captions,
    double? startPosition,
    bool allowsPictureInPicture = false,
  }) async {
    final result = await methodChannel.invokeMethod<num>('play', {
      "url": url,
      "videoTitle": videoTitle,
      "videoDescription": videoDescription,
      "captions": convertCaptions(captions ?? []),
      if (startPosition != null) "startPosition": startPosition,
      "allowsPictureInPicture": allowsPictureInPicture,
    });
    return result?.toDouble();
  }

  @override
  Future<double> getPosition(int viewId) async {
    final result = await methodChannel.invokeMethod<num>('getPosition', {
      "viewId": viewId,
    });
    return result?.toDouble() ?? -1.0;
  }

  @override
  Future<void> seekTo(int viewId, double position) async {
    await methodChannel.invokeMethod('seekTo', {
      "viewId": viewId,
      "position": position,
    });
  }

  @override
  Future<void> resume(int viewId) async {
    await methodChannel.invokeMethod('resume', {"viewId": viewId});
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
