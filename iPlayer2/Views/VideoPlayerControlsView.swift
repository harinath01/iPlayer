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
    var videoDuration: Float64!
    

    @IBOutlet weak var playPauseButton: UIButton!
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
        let seekTo = Float64(slider!.value) * videoDuration
        delegate?.goTo(seconds: Float(seekTo))
        slider.value = Float(seekTo/videoDuration)
        delegate.play()
    }
    
    func updateVideoPlayerSlider(currentTime: Float64, videoDuration: Float64){
        self.videoDuration = videoDuration
        if(!delegate.isPlaying()) {
            return
        }
        
        slider.value = Float(currentTime/videoDuration)
    }
}


protocol PlayerControlDelegate {
    func isPlaying() -> Bool
    func pause()
    func play()
    func forward()
    func rewind()
    func goTo(seconds:Float)
    func fullScreen()
}
