//
//  VideoPlayerControlsView.swift
//  iPlayer2
//
//  Created by Testpress on 30/04/23.
//

import Foundation
import UIKit


class VideoPlayerControlsView: UIView {
    
    var delegate: PlayerControlDelegate!
    var playerStatus: PlayerStatus? = .readyToPlay {
        didSet {
            refreshPlayPauseButton(playerStatus!)
        }
    }
    var timer: Timer!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var fullscreenToggleButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var dividerLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUp(){
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        resetTimer()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        self.addGestureRecognizer(tapGesture)
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }
    
    func refreshPlayPauseButton(_ playerStatus: PlayerStatus){
        switch self.playerStatus {
        case .readyToPlay:
            self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        case .playing:
            self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        case .paused:
            self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        case .finished:
            timer.invalidate()
            hideControls()
            self.playPauseButton.isHidden = false
            self.playPauseButton.setImage(UIImage(named: "reload"), for: .normal)
        case .none:
            return
        }
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        switch self.playerStatus {
        case .finished:
            delegate.reload()
            playPauseButton.isHidden = true
        case .paused, .readyToPlay:
            delegate.play()
        case .playing:
            delegate.pause()
        default:
            return
        }
    }
    
    @IBAction func playbackSliderChanged(_ sender: UISlider) {
        timer.invalidate()
        if (!sender.isTracking){
            let videoDuration = delegate.getDuration()
            let seekTo = Float64(slider!.value) * videoDuration
            delegate?.goTo(seconds: seekTo)
            slider.value = Float(seekTo/videoDuration)
        }
        resetTimer()
    }
    
    @IBAction func rewind(_ sender: Any) {
        delegate.rewind()
    }
    
    
    @IBAction func forward(_ sender: UIButton) {
        delegate.forward()
    }
    
    @IBAction func toggleFullscreen(_ sender: UIButton) {
        delegate.fullScreen()
    }
    
    func updatePlayerState(currentTime: Float64? = nil){
        if slider.isTracking {
          return
        }
        let currentTime = currentTime ?? delegate.getCurrentTime()
        slider.value = Float(currentTime/delegate.getDuration())
        currentTimeLabel.text = formatDuration(currentTime)
        durationLabel.text = formatDuration(delegate.getDuration())
    }
    
    @objc func hideControls() {
        playPauseButton.isHidden = true
        slider.isHidden = true
        currentTimeLabel.isHidden = true
        durationLabel.isHidden = true
        forwardButton.isHidden = true
        rewindButton.isHidden = true
        settingsButton.isHidden = true
        fullscreenToggleButton.isHidden = true
        dividerLabel.isHidden = true
        self.backgroundColor = nil
    }
    
    @objc func toggleControls() {
        if self.playerStatus == .finished{
            return
        }
        
        playPauseButton.isHidden = !playPauseButton.isHidden
        slider.isHidden = !slider.isHidden
        durationLabel.isHidden = !durationLabel.isHidden
        forwardButton.isHidden = !forwardButton.isHidden
        rewindButton.isHidden = !rewindButton.isHidden
        settingsButton.isHidden = !settingsButton.isHidden
        fullscreenToggleButton.isHidden = !fullscreenToggleButton.isHidden
        currentTimeLabel.isHidden = !currentTimeLabel.isHidden
        dividerLabel.isHidden = !dividerLabel.isHidden
        toggleBackgroundColor()
        resetTimer()
    }
    
    func toggleBackgroundColor(){
        if self.backgroundColor == nil {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        } else {
            self.backgroundColor = nil
        }
    }
}


protocol PlayerControlDelegate {
    func isPlaying() -> Bool
    func pause()
    func play()
    func reload()
    func forward()
    func rewind()
    func goTo(seconds:Float64)
    func fullScreen()
    func getDuration() -> Float64
    func getCurrentTime() -> Float64
}
