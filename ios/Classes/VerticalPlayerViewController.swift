//
//  VerticalPlayerViewController.swift
//  jwplayer
//
//  Created by MARK FRANSEN on 7/25/24.
//

import Foundation
import UIKit
import JWPlayerKit

struct Caption {
    let url: String
    let locale: String
    let languageLabel: String

    init?(from dictionary: [String: Any]) {
        guard let url = dictionary["url"] as? String,
              let locale = dictionary["locale"] as? String,
              let languageLabel = dictionary["languageLabel"] as? String else {
            return nil
        }
        self.url = url
        self.locale = locale
        self.languageLabel = languageLabel
    }
}

class VerticalPlayerViewController: JWPlayerViewController {
    var url: String?
    var videoTitle: String?
    var videoDescription: String?
    var captions: [Caption]?
    
    private let closeButton: UIButton = {
        if #available(iOS 13.0, *) {
            let closeButton = UIButton(type: .close)
            closeButton.backgroundColor = .black
            closeButton.layer.cornerRadius = 20
            return closeButton
        } else {
            let closeButton = UIButton()
            closeButton.setTitle("X", for: .normal)
            closeButton.setTitleColor(.black, for: .normal)
            closeButton.backgroundColor = .white
            closeButton.layer.cornerRadius = 20
            closeButton.layer.borderWidth = 1
            closeButton.layer.borderColor = UIColor.black.cgColor
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            
            return closeButton
        }
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.setCloseButtonBackground()
            }
        } else {
            // Fallback on earlier versions
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.closeButton.addTarget(self, action: #selector(dismissPlayer), for: .touchUpInside)
        
        do {
            let skin = try JWPlayerSkinBuilder()
                .titleIsVisible(videoTitle != nil && !(videoTitle?.isEmpty ?? true))
                .descriptionIsVisible(videoDescription != nil && !(videoDescription?.isEmpty ?? true))
                .build()
            // Set skin for player
            // Specifically, for us, show/hide title and description
            styling = skin
            forceLandscapeOnFullScreen = false
            forceFullScreenOnLandscape = false
        
            var captionTracks: [JWMediaTrack] = []
            captions?.forEach { caption in
                do {
                    if let captionUrl = URL(string: caption.url ?? "")
                        {
                        let captionTrack = try JWCaptionTrackBuilder()
                            .file(captionUrl)
                            .locale(caption.locale)
                            .label(caption.languageLabel)
                            .build()

                            captionTracks.append(captionTrack)
                        }
                } catch {
                    print("Failed to build caption track: \(error)")
                }
            }

            // Create a JWPlayerItem
            let item = try JWPlayerItemBuilder()
                .file(URL(string: url ?? "")!)
                .title(videoTitle ?? "")
                .description(videoDescription ?? "")
                .mediaTracks(captionTracks)
                .build()
            
            // Create a config, and give it the item as a playlist.
            let config = try JWPlayerConfigurationBuilder()
                .playlist(items: [item])
                .autostart(true)
                .build()
            
            // Set the config
            player.configurePlayer(with: config)
        }
        catch let error {
            // Handle Error
            print("something went wrong \(error.localizedDescription)")
            print("something went wrong \(error)")
        }
        
        // Setup the default rendering style for side-loaded captions.
        do {
            // Change the caption style
            let style = try JWCaptionStyleBuilder()
                .allowScaling(true)
                .build()
            
            playerView.captionStyle = style
        }
        catch {
            // Handle error
        }
    }
    
    private func setCloseButtonBackground() {
        if traitCollection.userInterfaceStyle == .dark {
            closeButton.backgroundColor = .black
        } else {
            closeButton.backgroundColor = .white
        }
    }
    
    private func setupUI() {
        self.setCloseButtonBackground()
        self.view.addSubview(closeButton)
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40), // Set icon size
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func dismissPlayer() {
        self.dismiss(animated: true)
    }
    
    override func jwplayer(_ player: JWPlayer, didPauseWithReason reason: JWPauseReason) {
        super.jwplayer(player, didPauseWithReason: reason)
        // Implement custom behavior
    }
    
    // MARK: - JWPlayerDelegate
    
    
    // Player is ready
    override func jwplayerIsReady(_ player: JWPlayer) {
        super.jwplayerIsReady(player)
        
    }
    
    // Setup error
    override func jwplayer(_ player: JWPlayer, failedWithSetupError code: UInt, message: String) {
        super.jwplayer(player, failedWithSetupError: code, message: message)
        
    }
    
    // Error
    override func jwplayer(_ player: JWPlayer, failedWithError code: UInt, message: String) {
        super.jwplayer(player, failedWithError: code, message: message)
        
    }
    
    // Warning
    override func jwplayer(_ player: JWPlayer, encounteredWarning code: UInt, message: String) {
        super.jwplayer(player, encounteredWarning: code, message: message)
        
    }
    
    // Ad error
    override func jwplayer(_ player: JWPlayer, encounteredAdError code: UInt, message: String) {
        super.jwplayer(player, encounteredAdError: code, message: message)
        
    }
    
    // Ad warning
    override func jwplayer(_ player: JWPlayer, encounteredAdWarning code: UInt, message: String) {
        super.jwplayer(player, failedWithSetupError: code, message: message)
        
    }
}

