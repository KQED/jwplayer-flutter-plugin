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
    
    private let closeButton: UIButton = {
        if #available(iOS 13.0, *) {
            let closeButton = UIButton(type: .close)
            closeButton.backgroundColor = .white
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.closeButton.addTarget(self, action: #selector(dismissPlayer), for: .touchUpInside)
        
        do {
            // Create a JWPlayerItem
            let item = try JWPlayerItemBuilder()
                .file(URL(string: url ?? "")!)
                .build()
            
            // Create a config, and give it the item as a playlist.
            let config = try JWPlayerConfigurationBuilder()
                .playlist(items: [item])
                .autostart(false)
                .build()
            
            // Set the config
            player.configurePlayer(with: config)
        }
        catch {
            // Handle Error
        }
    }
    
    private func setupUI() {
        self.view.addSubview(closeButton)
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
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

