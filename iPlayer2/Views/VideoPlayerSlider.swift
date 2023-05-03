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
    var bufferedLayer: CALayer!
    
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
        bufferedLayer = CALayer()
        bufferedLayer.backgroundColor = UIColor.gray.cgColor
        if let subviews = subviews as? [UIView] {
            for subview in subviews {
                print(subview)
                if let progressBar = subview as? UIProgressView {
                    print("called")
                    progressBar.layer.addSublayer(bufferedLayer)
                }
            }
        }
        updateBufferedLayer()
    }
    
    fileprivate func updateBufferedLayer() {
        let bufferedWidth = self.bounds.width * CGFloat(currentBuffer)
        bufferedLayer.frame = CGRect(x: 0, y: 0, width: bufferedWidth, height: 2.5)
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
    
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let beganTracking = super.beginTracking(touch, with: event)
        showTooltip()
        return beganTracking
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let continuedTracking = super.continueTracking(touch, with: event)
        updateTooltip()
        return continuedTracking
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        hideTooltip()
    }
    
    func showTooltip(){}
    
    func updateTooltip(){}
    
    func hideTooltip(){}
}
