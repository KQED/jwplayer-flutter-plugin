import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'jwplayer_platform_interface.dart';

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

  static const String _viewType = 'org.kqed.jwplayer/jwplayer_view';

  Map<String, dynamic> get _creationParams => {
        'url': url,
        'videoTitle': videoTitle ?? '',
        'videoDescription': videoDescription ?? '',
        'captions': captions?.map((c) => c.toMap()).toList() ?? [],
      };

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
              style: DefaultTextStyle.of(context).style.copyWith(
                    color: const Color(0xFFFFFFFF),
                  ),
            ),
          ),
        ),
      );
    }

    final platformView = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => UiKitView(
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      TargetPlatform.android => AndroidView(
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      _ => ColoredBox(
          color: const Color(0xFF000000),
          child: Center(
            child: Text(
              'JWPlayer is not supported on this platform',
              style: DefaultTextStyle.of(context).style.copyWith(
                    color: const Color(0xFFFFFFFF),
                  ),
            ),
          ),
        ),
    };

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: platformView,
    );
  }
}
