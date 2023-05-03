//
//  VideoPlayerSlider.swift
//  iPlayer2
//
//  Created by Testpress on 02/05/23.
//

import Foundation
import UIKit

class VideoPlayerSlider: UISlider {
    var currentBuffer: Float = 0.5
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize(){
        changeSliderThumbSize()
        self.maximumTrackTintColor = UIColor.lightGray.withAlphaComponent(0.4)
    }
    
    fileprivate func changeSliderThumbSize() {
        setThumbImage(currentThumbImage?.resize(toWidth: 24), for: UIControl.State.normal)
        setThumbImage(currentThumbImage?.resize(toWidth: 40), for: UIControl.State.highlighted)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
       var newBounds = super.trackRect(forBounds: bounds)
       newBounds.size.height = 2.5
       return newBounds
    }
}
