//
//  ScrollableVerticalVideoView.swift
//  jwplayer
//
//  Created by Carl Wills on 8/13/24.
//

import SwiftUI

struct ScrollableVerticalVideoView: View {
    let videos: [String] = ["https://cdn.jwplayer.com/manifests/BZwphBHN.m3u8", "https://cdn.jwplayer.com/manifests/7WmvDLh5.m3u8", "https://cdn.jwplayer.com/manifests/msDsS3xh.m3u8", "https://cdn.jwplayer.com/manifests/g03aOQbO.m3u8",
        "https://cdn.jwplayer.com/manifests/NSui2A4a.m3u8",
        "https://cdn.jwplayer.com/manifests/BZwphBHN.m3u8"]

    
    var body: some View {
        HStack{
            
            Spacer()
            TabView() {
                ForEach(videos, id: \.self) { video in
                    
                    
                    JWPlayerWrapperView(url: video).tag(video)
                        .rotationEffect(.degrees(-90)) // Rotate content back to original orientation
                        .frame(
                            width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.height,
                            alignment: .center).ignoresSafeArea(.all)
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width) // Adjust the frame to match rotation
                .rotationEffect(.degrees(90)) // Rotate TabView to make it scroll vertically
                .background(Color.black)
            Spacer()
        }
    }
}

#Preview {
    ScrollableVerticalVideoView()
}
