//
//  VideoResourceLoaderDelegate.swift
//  iPlayer2
//
//  Created by Testpress on 06/05/23.
//

import Foundation
import AVKit

class VideoPlayerResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    var contentKeySession: AVContentKeySession
    
    init(_ contentKeySession: AVContentKeySession){
        self.contentKeySession = contentKeySession
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else {
            debugPrint("Unable to read the url/host data.")
            loadingRequest.finishLoading(with: DRMError.noURLFound)
            return false
        }
        
        if url.scheme == "skd"{
            contentKeySession.processContentKeyRequest(withIdentifier: url, initializationData: nil, options: nil)
            return true
        }
        
        return false
    }
}

