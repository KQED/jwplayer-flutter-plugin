import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jwplayer_method_channel.dart';

abstract class JwplayerPlatform extends PlatformInterface {
  /// Constructs a JwplayerPlatform.
  JwplayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static JwplayerPlatform _instance = MethodChannelJwplayer();

  /// The default instance of [JwplayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelJwplayer].
  static JwplayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JwplayerPlatform] when
  /// they register themselves.
  static set instance(JwplayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init(String licenseKey) {
    throw UnimplementedError(
        'init(String licenseKey) has not been implemented.');
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> play(
    String url,
    String? videoTitle,
    String? videoDescription,
    List<Caption>? captions,
  ) {
    throw UnimplementedError('play(String url) has not been implemented.');
  }
}

class Caption {
  Caption({
    required this.url,
    required this.locale,
    required this.languageLabel,
  });

  final String url;
  final String locale;
  final String languageLabel;

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'locale': locale,
      'languageLabel': languageLabel,
    };
  }

  @override
  String toString() {
    return 'Caption(url: $url, locale: $locale, languageLabel: $languageLabel )';
  }
}
