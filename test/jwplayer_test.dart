import 'package:flutter_test/flutter_test.dart';
import 'package:jwplayer/jwplayer.dart';
import 'package:jwplayer/jwplayer_platform_interface.dart';
import 'package:jwplayer/jwplayer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJwplayerPlatform
    with MockPlatformInterfaceMixin
    implements JwplayerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> init(String licenseKey) {
    throw UnimplementedError();
  }

  @override
  Future<void> play(String url) {
    throw UnimplementedError();
  }
}

void main() {
  final JwplayerPlatform initialPlatform = JwplayerPlatform.instance;

  test('$MethodChannelJwplayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelJwplayer>());
  });

  test('getPlatformVersion', () async {
    Jwplayer jwplayerPlugin = Jwplayer();
    MockJwplayerPlatform fakePlatform = MockJwplayerPlatform();
    JwplayerPlatform.instance = fakePlatform;

    expect(await jwplayerPlugin.getPlatformVersion(), '42');
  });
}
