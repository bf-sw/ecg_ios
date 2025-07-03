//
//  SplashVideoPlayerView.swift
//  ecg
//
//  Created by insung on 7/1/25.
//


import SwiftUI
import AVKit

struct SplashVideoPlayerView: UIViewControllerRepresentable {
    var onFinished: () -> Void
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()

        if let path = Bundle.main.path(forResource: "splash", ofType: "mp4") {
            let player = AVPlayer(url: URL(fileURLWithPath: path))
            player.isMuted = true
            player.play()
            
            controller.player = player
            controller.showsPlaybackControls = false
            controller.videoGravity = .resizeAspectFill
            
            // 영상 종료 알림 등록
            NotificationCenter.default.addObserver(
                context.coordinator,
                selector: #selector(Coordinator.playerDidFinishPlaying),
                name: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinished: onFinished)
    }

    class Coordinator: NSObject {
        let onFinished: () -> Void

        init(onFinished: @escaping () -> Void) {
            self.onFinished = onFinished
        }

        @objc func playerDidFinishPlaying() {
            onFinished()
        }
    }
}
