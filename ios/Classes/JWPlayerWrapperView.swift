//
//  JWPlayerWrapper.swift
//  jwplayer
//
//  Created by Carl Wills on 8/13/24.
//

import SwiftUI
import JWPlayerKit

struct JWPlayerWrapperView: UIViewControllerRepresentable {
    var url: String

    func makeUIViewController(context: Context) -> VerticalPlayerViewController {
        var vc = VerticalPlayerViewController()
        vc.url = url
        return vc
    }

    func updateUIViewController(_ uiViewController: VerticalPlayerViewController, context: Context) {
        // Update the view controller if needed
    }
}
