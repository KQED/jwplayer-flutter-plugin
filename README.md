# jwplayer

This repo provides a bridge between Flutter and JWPlayer's native iOS and Android SDKs.

JWPlayer iOS SDK docs: https://docs.jwplayer.com/players/docs/ios-overview
JWPlayer Android SDK docs: https://docs.jwplayer.com/players/docs/android-overview

The current behavior of this plugin is to launch a native view fullscreen over the 
Flutter app and auto play the video from the URL provided.
A close button, X, is provided to dismiss the view and return to the Flutter app.

## Getting Started

### Add the dependency to pubspec.yaml:
ref shown is the current ref at the time of writing this README.md
If you want the latest, omit that line.
```
jwplayer:
  git:
    url: https://github.com/KQED/jwplayer-flutter-plugin.git
    ref: 7d1f50f7e356010a86eda6f0af31faccf269d706
```

### Set up a JWPlayer object
```
final jwPlayerPlugin = JWPlayer();
```

### Initialize JWPlayer with platform license key:
Add the following to initState():
```
// Platform messages are asynchronous, so we initialize in an async method.
Future<void> initPlatformState() async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  // We also handle the message potentially returning null.
  try {
    await jwPlayerPlugin.init(jwplayerLicenseKey);
  } on PlatformException {
    if (kDebugMode) {
      log('PlatformException in JWPlayer in debug mode');
    }
  }
}
```

### Set up MethodChannel and register for callbacks:
Add the following to initState():
```
void registerForCallbacks() {
  _pluginCallbacksChannel.setMethodCallHandler(_callbackMethodCallHandler);
}

Future<void> _callbackMethodCallHandler(MethodCall call) async {
  switch (call.method) {
    default:
    Future.delayed(Duration.zero, () {
      final data =
       'Method Call Triggered: ${call.method} with arguments ${call.arguments}';
        log('Method callback message: $data');
    });
  }
}
```

### Play a video:
```
jwPlayerPlugin.play(url);
```
