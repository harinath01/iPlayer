import Foundation
import UIKit
import AVKit

class VideoPlayerView: UIView, PlayerControlDelegate{    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var url: URL!
    var DRMLicenseURL: String?
    var timeObserver: Any?
    var videoPlayerControlsView: VideoPlayerControlsView! = .fromNib("VideoPlayerControls")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, url: URL!, DRMLicenseURL: String?) {
        self.url = url
        self.DRMLicenseURL = DRMLicenseURL
        super.init(frame: frame)
        setupPlayer()
        videoPlayerControlsView.frame = bounds
        videoPlayerControlsView.delegate = self
        videoPlayerControlsView.setUp()
        self.addSubview(videoPlayerControlsView)
        addObservers()
    }
    
    private func setupPlayer(){
        backgroundColor = .black
        player = AVPlayer(url: self.url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
    }
    
    private func addObservers(){
        let interval = CMTime(value: 1, timescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { progressTime in
            self.videoPlayerControlsView.updateVideoPlayerSlider(
                currentTime: CMTimeGetSeconds(progressTime),
                videoDuration: self.player.durationInSeconds
            )
        })
    }
    
    func isPlaying() -> Bool {
        return self.player.isPlaying
    }
    
    func pause() {
        self.player.pause()
    }
    
    func play() {
        self.player.play()
    }
    
    func forward() {
        
    }
    
    func rewind() {
        
    }
    
    func goTo(seconds: Float) {
        let seekTime = CMTime(value: Int64(seconds), timescale: 1)
        player?.seek(to: seekTime)
    }
    
    func fullScreen() {
        
    }
}
