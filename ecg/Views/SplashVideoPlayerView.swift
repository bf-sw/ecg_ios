import SwiftUI
import AVKit

struct SplashVideoPlayerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        if let path = Bundle.main.path(forResource: "splash", ofType: "mp4") {
            let player = AVPlayer(url: URL(fileURLWithPath: path))
            player.isMuted = true
            player.play()
            
            controller.player = player
            controller.showsPlaybackControls = false
            controller.videoGravity = .resizeAspectFill
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
