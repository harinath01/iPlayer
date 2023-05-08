import Foundation
import UIKit
import AVKit
import M3U8Kit

class VideoPlayerView: UIView, PlayerControlDelegate{    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var url: URL!
    var timeObserver: Any!
    var videoEndObserver: Any!
    var videoPlayerControlsView: VideoPlayerControlsView! = .fromNib("VideoPlayerControls")
    var isSeeking: Bool = false
    var frameInParentView: CGRect!
    var parentView: UIView?
    var availableResolutions:[VideoQuality] = [VideoQuality(resolution:"Auto", bitrate: 0)]
    
    // Define these as propery of class, to prevent the delegates from being deallocated,
    var contentKeySessionDelegate: DRMKeySessionDelegate!
    var contentKeySession: AVContentKeySession!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, url: URL!) {
        self.url = url
        super.init(frame: frame)
        setupPlayer()
        setupPlayerControls()
        addObservers()
    }
    
    private func setupPlayer(){
        backgroundColor = .black
        let playerItem = getPlayerItem()
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        self.parseAvailableResolutionsFromManifest()
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
    
    func getPlayerItem() -> AVPlayerItem{
        let asset = AVURLAsset(url: url)
        contentKeySession = createContentKeySession()
        contentKeySession.addContentKeyRecipient(asset)
        return AVPlayerItem(asset: asset)
    }
    
    func createContentKeySession() -> AVContentKeySession{
        let contentKeySession = AVContentKeySession(keySystem: AVContentKeySystem.fairPlayStreaming)
        contentKeySessionDelegate = DRMKeySessionDelegate(licenseURL: "https://app.tpstreams.com/api/v1/edee9b/assets/4A7M7nUYnX9/drm_license/?access_token=e258e9b9-e4c4-473f-8f01-40198e7d37c2&drm_type=fairplay")
        contentKeySession.setDelegate(contentKeySessionDelegate, queue: DispatchQueue.main)
        return contentKeySession
    }
    
    func parseAvailableResolutionsFromManifest(){
        do {
            availableResolutions.removeAll()
            availableResolutions = [VideoQuality(resolution:"Auto", bitrate: 0)]
            let playlistModel = try M3U8PlaylistModel(url: url)
            let masterPlaylist = playlistModel.masterPlaylist
            guard let streamList = masterPlaylist?.xStreamList else {
                return
            }
            streamList.sortByBandwidth(inOrder: .orderedAscending)
            
            for i in 0 ..< streamList.count {
                if let extXStreamInf = streamList.xStreamInf(at: i){
                    let resolution = "\(Int(extXStreamInf.resolution.height))p"
                    availableResolutions.append(VideoQuality(resolution: resolution, bitrate: extXStreamInf.bandwidth))
                }
            }
        } catch {}
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
            if videoPlayerControlsView.playerStatus != .finished{
                videoPlayerControlsView.playerStatus = .paused
            }
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
    
    func changePlaybackSpeed(speed: PlaybackSpeed){
        player.rate = speed.value
    }
    
    func changeBitrate(_ bitrate: Int) {
        player?.currentItem?.preferredPeakBitRate = Double(bitrate)
    }
    
    func showOptionsMenu(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Video Quality", style: .default, handler: { action in
            self.showQualityMenu()
        }))
        alert.addAction(UIAlertAction(title: "Playback Speed", style: .default, handler: { action in
            self.showPlaybackSpeedMenu()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showQualityMenu(){
        let alert = UIAlertController(title: "Playback Speed", message: nil, preferredStyle: .actionSheet)
        for resolutionInfo in self.availableResolutions {
            let action = UIAlertAction(title: resolutionInfo.resolution, style: .default, handler: { (_) in
                self.changeBitrate(resolutionInfo.bitrate)
            })
            
            if (Double(resolutionInfo.bitrate) == player?.currentItem?.preferredPeakBitRate) {
                action.setValue(UIImage(named: "checkmark"), forKey: "image")
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showPlaybackSpeedMenu(){
        let alert = UIAlertController(title: "Playback Speed", message: nil, preferredStyle: .actionSheet)

        for playbackSpeed in PlaybackSpeed.allCases {
            let action = UIAlertAction(title: playbackSpeed.label, style: .default) { [weak self] _ in
                self?.changePlaybackSpeed(speed: playbackSpeed)
            }

            if playbackSpeed == .normal && player.rate == 0.0 || (playbackSpeed.value == player.rate) {
                action.setValue(UIImage(named: "checkmark"), forKey: "image")
            }

            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
    }
}
