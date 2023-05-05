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
    var playerStatus: PlayerStatus = .readyToPlay {
        didSet {
            refreshPlayPauseButton(playerStatus)
        }
    }
    var timer: Timer!
    var isFullScreen = false
    var loadingIndicator: UIActivityIndicatorView?
    
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
        addTapGestureRecognize()
        startLoading()
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }
    
    func addTapGestureRecognize(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        self.addGestureRecognizer(tapGesture)
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
            self.playPauseButton.setImage(UIImage(named: "reload"), for: .normal)
            self.playPauseButton.isHidden = false
        }
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        switch self.playerStatus {
        case .finished:
            delegate.reload()
            playPauseButton.isHidden = true
        case .paused, .readyToPlay:
            delegate.play()
            if(!delegate.canPlay()){
                startLoading()
            }
        case .playing:
            delegate.pause()
            if(loadingIndicator?.isAnimating == true){
                stopLoading()
            }
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
        if !isFullScreen{
            delegate.enterFullScreen()
            isFullScreen = true
            self.fullscreenToggleButton.setImage(UIImage(named: "minimize"), for: .normal)
        }else{
            delegate.exitFullScreen()
            isFullScreen = false
            self.fullscreenToggleButton.setImage(UIImage(named: "maximize"), for: .normal)
        }
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
        let controls = [
            slider, currentTimeLabel, durationLabel,
            forwardButton, rewindButton, settingsButton, fullscreenToggleButton,
            dividerLabel
        ]
        
        controls.forEach { $0!.isHidden = true }
        if loadingIndicator?.isAnimating == false{
            playPauseButton.isHidden = true
        }
        backgroundColor = nil
    }

    @objc func toggleControls() {
        guard playerStatus != .finished else { return }
        let controls = [
            slider, durationLabel, forwardButton,
            rewindButton, settingsButton, fullscreenToggleButton,
            currentTimeLabel, dividerLabel
        ]
        
        controls.forEach { $0!.isHidden.toggle() }
        if loadingIndicator?.isAnimating == false {
            playPauseButton.isHidden.toggle()
        }
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
    
    func startLoading(){
        loadingIndicator = getLoadingIndicator() 
        playPauseButton.setImage(nil, for: .normal)
        playPauseButton.setTitle("", for: .normal)
        playPauseButton.addSubview(loadingIndicator!)
        loadingIndicator!.startAnimating()
    }
    
    func stopLoading(){
        loadingIndicator?.stopAnimating()
        refreshPlayPauseButton(playerStatus)
    }
    
    func getLoadingIndicator() -> UIActivityIndicatorView{
        if loadingIndicator != nil{
            return loadingIndicator!
        }
        
        let newLoadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        newLoadingIndicator.hidesWhenStopped = true
        newLoadingIndicator.isUserInteractionEnabled = false
        newLoadingIndicator.center = CGPoint(
            x: playPauseButton.bounds.size.width/2,
            y: playPauseButton.bounds.size.height/2
        )
        return newLoadingIndicator
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
    func enterFullScreen()
    func exitFullScreen()
    func getDuration() -> Float64
    func getCurrentTime() -> Float64
    func canPlay() -> Bool
}
