//
//  AVPlayer.swift
//  iPlayer2
//
//  Created by Testpress on 30/04/23.
//

import AVKit

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
    
    var currentTimeInSeconds: Float64 {
        return CMTimeGetSeconds(currentTime())
    }
    
    var durationInSeconds: Float64 {
        return CMTimeGetSeconds(currentItem?.duration ?? CMTime.zero)
    }
}
