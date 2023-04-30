import Foundation
import UIKit
import AVKit

class VideoPlayerView: UIView {
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var url: URL!
    var DRMLicenseURL: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, url: URL!, DRMLicenseURL: String?) {
        self.url = url
        self.DRMLicenseURL = DRMLicenseURL
        super.init(frame: frame)
        setupPlayer()
        player.play()
    }
    
    private func setupPlayer(){
        backgroundColor = .black
        player = AVPlayer(url: self.url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
    }
}
