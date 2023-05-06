import Foundation
import UIKit
import AVKit

class VideoPlayerView: UIView, PlayerControlDelegate{    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var url: URL!
    var DRMLicenseURL: String?
    var timeObserver: Any!
    var videoEndObserver: Any!
    var videoPlayerControlsView: VideoPlayerControlsView! = .fromNib("VideoPlayerControls")
    var isSeeking: Bool = false
    var frameInParentView: CGRect!
    var parentView: UIView?
    
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
        // Player video end observer
        videoEndObserver = NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        // Player current time change observer
        let interval = CMTime(value: 1, timescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { progressTime in
            if !self.isSeeking {
                self.videoPlayerControlsView.updatePlayerState(
                    currentTime: CMTimeGetSeconds(progressTime)
                )
            }
        })
        
        // Player buffering observer
        player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        player.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if let player = object as? AVPlayer {
            if keyPath == "timeControlStatus" {
                handleTimeControlStatusChange(for: player)
            }
        } else if let playerItem = object as? AVPlayerItem {
            handlePlayerItemChange(for: playerItem, keyPath: keyPath)
        }
    }

    private func handleTimeControlStatusChange(for player: AVPlayer) {
        switch player.timeControlStatus {
        case .playing:
            videoPlayerControlsView.playerStatus = .playing
        case .paused:
            videoPlayerControlsView.playerStatus = .paused
        case .waitingToPlayAtSpecifiedRate:
            break
        @unknown default:
            break
        }
    }

    private func handlePlayerItemChange(for playerItem: AVPlayerItem, keyPath: String?) {
        switch keyPath {
        case #keyPath(AVPlayerItem.isPlaybackBufferEmpty):
            if playerItem.isPlaybackBufferEmpty {
                videoPlayerControlsView.startLoading()
            }
        case #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), #keyPath(AVPlayerItem.isPlaybackBufferFull):
            if playerItem.isPlaybackLikelyToKeepUp {
                videoPlayerControlsView.stopLoading()
            }
        default:
            break
        }
    }
    
    @objc func playerDidFinishPlaying() {
        videoPlayerControlsView.playerStatus = .finished
    }
    
    func isPlaying() -> Bool {
        return self.player.isPlaying
    }
    
    func canPlay() -> Bool{
        return self.player.currentItem?.isPlaybackLikelyToKeepUp == true
    }
    
    func play() {
        self.player.play()
    }
    
    func pause() {
        self.player.pause()
    }
    
    func reload(){
        goTo(seconds: 0.0)
        play()
    }
    
    func getDuration() -> Float64 {
        return self.player.durationInSeconds
    }
    
    func getCurrentTime() -> Float64 {
        return self.player.currentTimeInSeconds
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
            self.videoPlayerControlsView.updatePlayerState()
        }
    }
    
    func enterFullScreen(){
        UIDevice.current.setValue(
            UIInterfaceOrientation.landscapeRight.rawValue,
            forKey: "orientation"
        )
        parentView = superview
        frameInParentView = frame
        frame = UIScreen.main.bounds
        removeFromSuperview()
        UIApplication.shared.keyWindow!.addSubview(self)
        playerLayer.frame = bounds
    }
    
    func exitFullScreen(){
        UIDevice.current.setValue(
            UIInterfaceOrientation.portrait.rawValue,
            forKey: "orientation"
        )
        frame = frameInParentView
        removeFromSuperview()
        parentView!.addSubview(self)
        playerLayer.frame = bounds
    }
}
