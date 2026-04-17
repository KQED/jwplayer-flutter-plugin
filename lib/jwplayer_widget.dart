import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'jwplayer_platform_interface.dart';

/// Invokes the native setMuted method for an embedded JWPlayer view.
///
/// Call this after the view is created (from [onPlatformViewCreated]).
Future<void> setJwplayerViewMuted(int viewId, bool muted) async {
  await const MethodChannel(
    'org.kqed.jwplayer',
  ).invokeMethod('setMuted', {'viewId': viewId, 'muted': muted});
}

/// A Flutter widget that embeds the native JWPlayer view.
///
/// Use this widget to display JWPlayer video inline within your app,
/// rather than launching the full-screen native player.
///
/// The [url] parameter is required. Ensure [Jwplayer.init] has been called
/// with a valid license key before displaying this widget.
class JwplayerWidget extends StatelessWidget {
  const JwplayerWidget({
    required this.url,
    super.key,
    this.videoTitle,
    this.videoDescription,
    this.captions,
    this.aspectRatio = 9.0 / 16.0,
    this.muted = true,
    this.startPosition,
    this.showControls = false,
    this.loop = false,
    this.onPlatformViewCreated,
  });

  /// The video URL to play (e.g. HLS manifest or MP4).
  final String url;

  /// Optional video title displayed in the player UI.
  final String? videoTitle;

  /// Optional video description displayed in the player UI.
  final String? videoDescription;

  /// Optional list of caption tracks.
  final List<Caption>? captions;

  /// Aspect ratio of the player (default 9:16 for vertical video).
  final double aspectRatio;

  /// Whether the player starts muted (default false).
  final bool muted;

  /// Start playback at this position in seconds. Use when resuming (e.g. full-screen).
  final double? startPosition;

  /// When true, show native player controls (play/pause, seek bar, etc.).
  /// Default false for embedded feed; use true for full-screen.
  final bool showControls;

  /// When true, the native player will restart the video when it completes.
  /// Defaults to false.
  final bool loop;

  /// Called when the native view is created, with the platform view ID.
  /// Use this to call [setJwplayerViewMuted] when toggling mute.
  final void Function(int viewId)? onPlatformViewCreated;

  static const String _viewType = 'org.kqed.jwplayer/jwplayer_view';

  Map<String, dynamic> get _creationParams {
    final params = <String, dynamic>{
      'url': url,
      'videoTitle': videoTitle ?? '',
      'videoDescription': videoDescription ?? '',
      'captions': captions?.map((c) => c.toMap()).toList() ?? [],
      'muted': muted,
    };
    if (startPosition != null && startPosition! > 0) {
      params['startPosition'] = startPosition;
    }
    params['showControls'] = showControls;
    params['loop'] = loop;
    return params;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: ColoredBox(
          color: const Color(0xFF000000),
          child: Center(
            child: Text(
              'JWPlayer is not supported on web',
              style: DefaultTextStyle.of(
                context,
              ).style.copyWith(color: const Color(0xFFFFFFFF)),
            ),
          ),
        ),
      );
    }

    final hitTestBehavior = showControls
        ? PlatformViewHitTestBehavior.opaque
        : PlatformViewHitTestBehavior.transparent;
    final platformView = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => UiKitView(
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
          hitTestBehavior: hitTestBehavior,
        ),
      TargetPlatform.android => _buildAndroidHybridView(
          onPlatformViewCreated,
          hitTestBehavior,
        ),
      _ => ColoredBox(
          color: const Color(0xFF000000),
          child: Center(
            child: Text(
              'JWPlayer is not supported on this platform',
              style: DefaultTextStyle.of(
                context,
              ).style.copyWith(color: const Color(0xFFFFFFFF)),
            ),
          ),
        ),
    };

    return AspectRatio(aspectRatio: aspectRatio, child: platformView);
  }

  /// Uses Hybrid Composition so the native view scrolls correctly with the feed.
  /// Default AndroidView uses SurfaceProducer which causes full-screen overlay
  /// when embedding video players (SurfaceView) in scrollable content.
  Widget _buildAndroidHybridView(
    void Function(int viewId)? onPlatformViewCreated,
    PlatformViewHitTestBehavior hitTestBehavior,
  ) {
    return PlatformViewLink(
      viewType: _viewType,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return PlatformViewSurface(
          controller: controller,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: hitTestBehavior,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        final controller = PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () => params.onFocusChanged(true),
        );
        controller.addOnPlatformViewCreatedListener(
          params.onPlatformViewCreated,
        );
        if (onPlatformViewCreated != null) {
          controller.addOnPlatformViewCreatedListener(onPlatformViewCreated);
        }
        controller.create();
        return controller;
      },
    );
  }
}
