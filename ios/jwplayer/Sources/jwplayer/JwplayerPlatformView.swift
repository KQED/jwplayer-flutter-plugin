import AVFoundation
import Flutter
import UIKit
import JWPlayerKit

private extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}

private func findRootViewController() -> UIViewController? {
    let window = UIApplication.shared.windows.first { $0.isKeyWindow }
    return window?.rootViewController
}

private enum JwAudioSession {
    private static var configured = false

    static func configureForPlaybackIfNeeded() {
        guard !configured else { return }
        configured = true

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .moviePlayback)
            try session.setActive(true)
        } catch {
            print("JWPlayer audio session setup failed: \(error)")
        }
    }
}

private final class JwplayerPlaybackDelegate: NSObject, JWPlayerStateDelegate {
    var loop: Bool = false
    /// When true, force volume to 0 on play attempts so autostart can run without an audible blip.
    var startMuted: Bool = false

    func jwplayer(_ player: JWPlayer, willPlayWithReason reason: JWPlayReason) {
        if startMuted {
            player.volume = 0
        }
    }

    func jwplayer(_ player: JWPlayer, isAttemptingToPlay playlistItem: JWPlayerItem, reason: JWPlayReason) {
        if startMuted {
            player.volume = 0
        }
    }

    func jwplayerContentDidComplete(_ player: JWPlayer) {
        if loop {
            player.seek(to: 0)
            player.play()
        }
    }

    func jwplayerContentWillComplete(_ player: JWPlayer) {}
    func jwplayer(_ player: JWPlayer, isBufferingWithReason reason: JWBufferReason) {}
    func jwplayer(_ player: JWPlayer, updatedBuffer percent: Double, position time: JWTimeData) {}
    func jwplayer(_ player: JWPlayer, didFinishLoadingWithTime loadTime: TimeInterval) {}
    func jwplayer(_ player: JWPlayer, isPlayingWithReason reason: JWPlayReason) {}
    func jwplayer(_ player: JWPlayer, didPauseWithReason reason: JWPauseReason) {}
    func jwplayer(_ player: JWPlayer, didBecomeIdleWithReason reason: JWIdleReason) {}
    func jwplayer(_ player: JWPlayer, isVisible: Bool) {}
    func jwplayer(_ player: JWPlayer, didLoadPlaylist playlist: [JWPlayerItem]) {}
    func jwplayer(_ player: JWPlayer, didLoadPlaylistItem item: JWPlayerItem, at index: UInt) {}
    func jwplayerPlaylistHasCompleted(_ player: JWPlayer) {}
    func jwplayer(_ player: JWPlayer, usesMediaType type: JWMediaType) {}
    func jwplayer(_ player: JWPlayer, seekedFrom oldPosition: TimeInterval, to newPosition: TimeInterval) {}
    func jwplayerHasSeeked(_ player: JWPlayer) {}
    func jwplayer(_ player: JWPlayer, playbackRateChangedTo rate: Double, at time: TimeInterval) {}
    func jwplayer(_ player: JWPlayer, updatedCues cues: [JWCue]) {}
}

class JwplayerPlatformView: NSObject, FlutterPlatformView {
    private var _view: JwplayerHostView
    private var playerView: JWPlayerView?
    private var playerViewController: JWPlayerViewController?
    private let viewId: Int64
    private var loop: Bool = false
    private var playbackDelegate: JwplayerPlaybackDelegate?
    private var isMuted: Bool = false

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        self.viewId = viewId
        _view = JwplayerHostView(frame: frame)
        super.init()
        _view.setupBlock = { [weak self] in
            self?.createNativeView(frame: frame, arguments: args)
        }
        JwplayerViewRegistry.register(viewId: viewId, view: self)
    }

    deinit {
        if let vc = playerViewController {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        JwplayerViewRegistry.unregister(viewId: viewId)
    }

    func view() -> UIView {
        return _view
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
        if let vc = playerViewController {
            vc.player.volume = muted ? 0 : 1
        } else {
            playerView?.player.volume = muted ? 0 : 1
        }
    }

    func getPosition() -> Double {
        if let vc = playerViewController {
            return vc.player.time.position
        }
        guard let player = playerView?.player else { return -1 }
        return player.time.position
    }

    func seekTo(_ position: Double) {
        if let vc = playerViewController {
            vc.player.seek(to: position)
        } else {
            playerView?.player.seek(to: position)
        }
    }

    func resume() {
        if let vc = playerViewController {
            vc.player.play()
        } else {
            playerView?.player.play()
        }
    }

    private func createNativeView(frame: CGRect, arguments args: Any?) {
        JwAudioSession.configureForPlaybackIfNeeded()

        guard let args = args as? [String: Any],
              let urlString = args["url"] as? String,
              let url = URL(string: urlString) else {
            return
        }

        let videoTitle = args["videoTitle"] as? String ?? ""
        let videoDescription = args["videoDescription"] as? String ?? ""
        let captionsArray = args["captions"] as? [[String: Any]] ?? []
        let muted: Bool = {
            if let b = args["muted"] as? Bool { return b }
            if let n = args["muted"] as? NSNumber { return n.boolValue }
            return false
        }()
        let startPosition = (args["startPosition"] as? NSNumber)?.doubleValue
        let showControls = (args["showControls"] as? NSNumber)?.boolValue ?? false
        loop = (args["loop"] as? NSNumber)?.boolValue ?? false
        isMuted = muted

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

            var itemBuilder = JWPlayerItemBuilder()
                .file(url)
                .title(videoTitle)
                .description(videoDescription)
                .mediaTracks(captionTracks)
            if let start = startPosition, start > 0 {
                itemBuilder = itemBuilder.startTime(start)
            }
            let item = try itemBuilder.build()

            let config = try JWPlayerConfigurationBuilder()
                .playlist(items: [item])
                .autostart(true)
                .build()

            if showControls, let parentVC = _view.parentViewController ?? findRootViewController() {
                let vc = JWPlayerViewController()
                parentVC.addChild(vc)
                _view.addSubview(vc.view)
                vc.view.frame = _view.bounds
                vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                vc.didMove(toParent: parentVC)
                vc.player.configurePlayer(with: config)
                vc.player.volume = muted ? 0 : 1
                self.playerViewController = vc

                if loop || muted, let jwPlayer = vc.player as? JWPlayer {
                    let delegate = JwplayerPlaybackDelegate()
                    delegate.loop = loop
                    delegate.startMuted = muted
                    jwPlayer.playbackStateDelegate = delegate
                    self.playbackDelegate = delegate
                }

                let style = try JWCaptionStyleBuilder()
                    .allowScaling(true)
                    .build()
                vc.playerView.captionStyle = style
            } else {
                let pv = JWPlayerView(frame: _view.bounds)
                pv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                _view.addSubview(pv)
                pv.player.configurePlayer(with: config)
                self.playerView = pv
                pv.player.volume = muted ? 0 : 1

                if loop || muted, let jwPlayer = pv.player as? JWPlayer {
                    let delegate = JwplayerPlaybackDelegate()
                    delegate.loop = loop
                    delegate.startMuted = muted
                    jwPlayer.playbackStateDelegate = delegate
                    self.playbackDelegate = delegate
                }

                let style = try JWCaptionStyleBuilder()
                    .allowScaling(true)
                    .build()
                pv.captionStyle = style
            }
        } catch {
            print("JwplayerPlatformView: Failed to configure player - \(error.localizedDescription)")
        }
    }
}

private class JwplayerHostView: UIView {
    var setupBlock: (() -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil, let block = setupBlock {
            setupBlock = nil
            block()
        }
    }
}
