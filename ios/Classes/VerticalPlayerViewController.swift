//
//  VerticalPlayerViewController.swift
//  jwplayer
//
//  Created by MARK FRANSEN on 7/25/24.
//

import Foundation
import UIKit
import JWPlayerKit

class VerticalPlayerViewController: JWPlayerViewController {
    var url: String?
    var videoTitle: String?
    var videoDescription: String?
    var captionUrl: String?
    var captionLocale: String?
    var captionLanguageLabel: String?
    
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
            // Change the font for both title and description
            // .font(UIFont (name: "HelveticaNeue-UltraLight", size: 30)!)
                .build()
            // Set skin for player
            // Specifically, for us, show/hide title and description
            styling = skin
            
            var captionTracks: [JWMediaTrack] = []
            if let captionUrl = URL(string: captionUrl ?? "") {
                captionTracks = [
                    try JWCaptionTrackBuilder()
                        .file(captionUrl)
                        .label(captionLanguageLabel ?? "English")
                        .locale(captionLocale ?? "en")
                        .defaultTrack(true)
                        .build()
                ]
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
            // Change the default position for the caption
//            let position = try JWCaptionPositionBuilder()
//                .width(percentage: 100)
//                .horizontalPosition(percentage: 0)
//                .alignment(.center)
//                .verticalPosition(lineIndex: 0)
//                .build()
            
            // Change the caption style
            let style = try JWCaptionStyleBuilder()
//                .font(UIFont(name: "Zapfino", size: 20)!)
//                .fontColor(.blue)
//                .highlightColor(.white)
//                .backgroundColor(UIColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 0.7))
//                .edgeStyle(.raised)
                    // add position created above
//                .position(position)
                .allowScaling(true)
                .build()
            
            // Supply the style to the player
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

