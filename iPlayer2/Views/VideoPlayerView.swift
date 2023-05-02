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
    var isSeeking: Bool = false
    var isFullScreen = false
    var frameInSuperview: CGRect!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, url: URL!, DRMLicenseURL: String?) {
        self.url = url
        self.DRMLicenseURL = DRMLicenseURL
        super.init(frame: frame)
        setupPlayer()
        setupPlayerControls()
        addObservers()
    }
    
    private func setupPlayer(){
        backgroundColor = .black
        player = AVPlayer(url: self.url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
    }
    
    private func setupPlayerControls(){
        videoPlayerControlsView.frame = bounds
        videoPlayerControlsView.delegate = self
        videoPlayerControlsView.setUp()
        self.addSubview(videoPlayerControlsView)
    }
    
    private func addObservers(){
        let interval = CMTime(value: 1, timescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { progressTime in
            if !self.isSeeking {
                self.videoPlayerControlsView.updatePlayerState(
                    currentTime: CMTimeGetSeconds(progressTime)
                )
            }
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
    
    func getDuration() -> Float64 {
        return self.player.durationInSeconds
    }
    
    func forward() {
        let duration = self.getDuration()
        let seekTo = self.player.currentTimeInSeconds + 10
        if seekTo > duration{
            return
        }
        goTo(seconds: seekTo)
    }
    
    func rewind() {
        var seekTo = self.player.currentTimeInSeconds - 10
        if seekTo < 0 {
            seekTo = 0
        }
        goTo(seconds: seekTo)
    }
    
    func goTo(seconds: Float64) {
        isSeeking = true
        let seekTime = CMTime(value: Int64(seconds), timescale: 1)
        player?.seek(
            to: seekTime,
            toleranceBefore: CMTime.zero,
            toleranceAfter: CMTime.zero
        ) { [weak self] _ in
            guard let `self` = self else { return }
            self.isSeeking = false
        }
    }
    
    func fullScreen() {
        let value: Any
        if !isFullScreen {
            self.frameInSuperview = self.frame
            value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            let rootView = self.superview
            self.removeFromSuperview()
            self.frame = rootView!.bounds
            rootView!.addSubview(self)
            self.playerLayer.frame = self.bounds
            isFullScreen = true
        } else {
            value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.removeFromSuperview()
            self.frame = self.frameInSuperview
            self.superview?.addSubview(self)
            self.playerLayer.frame = self.bounds
            isFullScreen = false
        }
        
    }
}
