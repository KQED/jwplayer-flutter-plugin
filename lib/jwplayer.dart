import 'jwplayer_platform_interface.dart';

export 'jwplayer_widget.dart';

class Jwplayer {
  Future<void> init(String licenseKey) {
    return JwplayerPlatform.instance.init(licenseKey);
  }

  Future<double?> play(
    String url, {
    String? videoTitle,
    String? videoDescription,
    List<Caption>? captions,
    double? startPosition,
  }) {
    return JwplayerPlatform.instance.play(
      url,
      videoTitle: videoTitle,
      videoDescription: videoDescription,
      captions: captions,
      startPosition: startPosition,
    );
  }

  Future<double> getPosition(int viewId) {
    return JwplayerPlatform.instance.getPosition(viewId);
  }

  Future<void> seekTo(int viewId, double position) {
    return JwplayerPlatform.instance.seekTo(viewId, position);
  }

  Future<void> resume(int viewId) {
    return JwplayerPlatform.instance.resume(viewId);
  }

  Future<String?> getPlatformVersion() {
    return JwplayerPlatform.instance.getPlatformVersion();
  }
}
