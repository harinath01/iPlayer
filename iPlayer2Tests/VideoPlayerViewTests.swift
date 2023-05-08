//
//  VideoPlayerViewTests.swift
//  iPlayer2Tests
//
//  Created by Testpress on 08/05/23.
//

import XCTest
import AVKit
@testable import iPlayer2

final class VideoPlayerViewTests: XCTestCase {
    var videoPlayerView: VideoPlayerView!
    
    override func setUpWithError() throws {
        videoPlayerView = VideoPlayerView(
            frame: CGRect(x:0, y:0, width:20, height:100),
            url: URL(string: "http://google.com")!,
            DRMLicenseURL: "https://license.com/contents/8938492/drm-license"
        )
    }

    override func tearDownWithError() throws {
        videoPlayerView = nil
    }
    
    func testInit() {
        XCTAssertTrue(videoPlayerView.videoPlayerControlsView.loadingIndicator?.isAnimating == true)
    
        let url: URL? = (videoPlayerView.player?.currentItem?.asset as? AVURLAsset)?.url
        XCTAssertEqual(url, URL(string: "http://google.com")!)
    }

    func testPlayMethod() throws {
        videoPlayerView.play()
        
        XCTAssertTrue(videoPlayerView.player.isPlaying)
    }
    
    func testPauseMethod() throws {
        videoPlayerView.pause()
        
        XCTAssertTrue(videoPlayerView.player.isPlaying == false)
    }
    
    func testPlayerShouldEnterFullScreen() {
        videoPlayerView.enterFullScreen()
        
        XCTAssertTrue(UIDevice.current.orientation.isLandscape)
    }
    
    func testPlayShouldUseCurrentPlaybackSpeed() {
        videoPlayerView.changePlaybackSpeed(speed: PlaybackSpeed.double)
        
        XCTAssertEqual(2, videoPlayerView.player.rate)
    }
}
