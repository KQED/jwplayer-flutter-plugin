import 'jwplayer_platform_interface.dart';

class Jwplayer {
  Future<void> init(String licenseKey) {
    return JwplayerPlatform.instance.init(licenseKey);
  }

  Future<void> play(String url, String? videoTitle, String? videoDescription) {
    return JwplayerPlatform.instance.play(url, videoTitle, videoDescription);
  }

  Future<String?> getPlatformVersion() {
    return JwplayerPlatform.instance.getPlatformVersion();
  }
}
