import Flutter
import UIKit
import JWPlayerKit

class JwplayerPlatformView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var playerView: JWPlayerView?

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView(frame: frame)
        super.init()
        createNativeView(frame: frame, arguments: args)
    }

    func view() -> UIView {
        return _view
    }

    private func createNativeView(frame: CGRect, arguments args: Any?) {
        guard let args = args as? [String: Any],
              let urlString = args["url"] as? String,
              let url = URL(string: urlString) else {
            return
        }

        let videoTitle = args["videoTitle"] as? String ?? ""
        let videoDescription = args["videoDescription"] as? String ?? ""
        let captionsArray = args["captions"] as? [[String: Any]] ?? []

        let playerView = JWPlayerView(frame: frame)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        _view.addSubview(playerView)

        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: _view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: _view.bottomAnchor)
        ])

        do {
            var captionTracks: [JWMediaTrack] = []
            for captionDict in captionsArray {
                if let caption = Caption(from: captionDict),
                   let captionUrl = URL(string: caption.url) {
                    let captionTrack = try JWCaptionTrackBuilder()
                        .file(captionUrl)
                        .locale(caption.locale)
                        .label(caption.languageLabel)
                        .build()
                    captionTracks.append(captionTrack)
                }
            }

            let item = try JWPlayerItemBuilder()
                .file(url)
                .title(videoTitle)
                .description(videoDescription)
                .mediaTracks(captionTracks)
                .build()

            let config = try JWPlayerConfigurationBuilder()
                .playlist(items: [item])
                .autostart(true)
                .build()

            playerView.player.configurePlayer(with: config)
            self.playerView = playerView

            let style = try JWCaptionStyleBuilder()
                .allowScaling(true)
                .build()
            playerView.captionStyle = style
        } catch {
            print("JwplayerPlatformView: Failed to configure player - \(error.localizedDescription)")
        }
    }
}
