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
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var fullscreenToggleButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var forwardButton: UIButton!
    
    
    @IBOutlet weak var slider: UISlider!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUp(){
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        if !delegate.isPlaying(){
            delegate.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            delegate.pause()
        }
    }
    @IBAction func playbackSliderChanged(_ sender: UISlider) {
        delegate.pause()
        let videoDuration = delegate.getDuration()
        let seekTo = Float64(slider!.value) * videoDuration
        delegate?.goTo(seconds: seekTo)
        slider.value = Float(seekTo/videoDuration)
        delegate.play()
    }
  
    @IBAction func rewind(_ sender: Any) {
        delegate.rewind()
    }
    
    
    @IBAction func forward(_ sender: UIButton) {
        delegate.forward()
    }
    
    
    
    func updatePlayerState(currentTime: Float64){
        slider.value = Float(currentTime/delegate.getDuration())
        currentTimeLabel.text = formatDuration(currentTime)
        durationLabel.text = formatDuration(delegate.getDuration())
    }
}


protocol PlayerControlDelegate {
    func isPlaying() -> Bool
    func pause()
    func play()
    func forward()
    func rewind()
    func goTo(seconds:Float64)
    func fullScreen()
    func getDuration() -> Float64
}
