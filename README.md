# jwplayer

This repo provides a bridge between Flutter and JWPlayer's native iOS and Android SDKs.

- JWPlayer iOS SDK docs: https://docs.jwplayer.com/players/docs/ios-overview
- JWPlayer Android SDK docs: https://docs.jwplayer.com/players/docs/android-overview

The current behavior of this plugin is to launch a native view fullscreen over the 
Flutter app and auto play the video from the URL provided.
A close button, X, is provided to dismiss the view and return to the Flutter app.

## Getting Started

### Add the dependency to pubspec.yaml:
The ref shown is the current ref at the time of writing this README.md.
If you want the latest, omit that line.
```
jwplayer:
  git:
    url: https://github.com/KQED/jwplayer-flutter-plugin.git
    ref: 608f02c3c219ed86dfb9257d8360d2a44b423684
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

### Updating the plugin code - iOS:
- Open `example/ios/Runner.xcworkspace` in Xcode
- Edit plugin components:
	- Open directory at Pods > Development Pods > jwplayer > .. > .. > example > ios > .symlinks > plugins > jwplayer > ios > Classes
	- Here you will find `JwplayerPlugin.swift` and `VerticalPlayerViewController.swift`
	  - `JwplayerPlugin.swift` handles interactions between the Flutter code, using method channels, and the `VerticalPlayerViewController.swift` file
	- You can run the plugin's iOS project with Runner.xcworkspace open in Xcode which will launch the plugin example 
	  - Edit the plugin code with Xcode's error checking, linting, code docs, etc.
	- Alternatively, you can run the plugin example in VsCode by opening the jwplayer-flutter-plugin directory
		- Open main.dart and run the project. The majority of the Flutter code lives direclty in main.dart
	- `VerticalPlayerViewController.swift` contains all the specific UI and player code for the view that appears in the Flutter project.
		- Any player settings, vertical video properties, like urls, etc, will most likely be updated in this file.
	- To test local plugin changes in the Flutter project, update the `jwplayer` package details in `pubspec.yaml`:
		- Replace the `git`, `url`, and `ref` lines with:
			- `path: /Users/markfransen/Uptech Studio/KQED/jwplayer-flutter-plugin`

### Updating the plugin code - Android:
- Open jwplayer-flutter-plugin/android in Android Studio
- The following files are where the plugin code lives:
  - CallbackMethods.kt
  - JwPlayerActivity.kt
  - JwplayerPlugin.kt
  - PluginMethods.kt

### Updating/running the example app code - Flutter:
- Open the jwplayer-flutter-plugin in VSCode
- Open example > lib > main.dart
- Here we can adjust the UI for the example app, test new changes, for example when captions are added to videos, etc.