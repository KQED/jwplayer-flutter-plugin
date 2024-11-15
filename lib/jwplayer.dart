import 'jwplayer_platform_interface.dart';

class Jwplayer {
  Future<void> init(String licenseKey) {
    return JwplayerPlatform.instance.init(licenseKey);
  }

  Future<void> play(
    String url, {
    String? videoTitle,
    String? videoDescription,
    List<Caption>? captions,
  }) {
    return JwplayerPlatform.instance.play(
      url,
      videoTitle,
      videoDescription,
      captions,
    );
  }

  Future<String?> getPlatformVersion() {
    return JwplayerPlatform.instance.getPlatformVersion();
  }
}
