//
//  DRMKeySessionDelegate.swift
//  iPlayer2
//
//  Created by Testpress on 06/05/23.
//

import Foundation
import AVFoundation

class DRMKeySessionDelegate: NSObject, AVContentKeySessionDelegate {
    let licenseURL: String
    
    public required init?(licenseURL: String) {
        self.licenseURL = licenseURL
    }
    
    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        handleStreamingContentKeyRequest(keyRequest: keyRequest)
    }
    
    func contentKeySession(_ session: AVContentKeySession, didProvideRenewingContentKeyRequest keyRequest: AVContentKeyRequest) {
        handleStreamingContentKeyRequest(keyRequest: keyRequest)
    }
    
    func contentKeySession(_ session: AVContentKeySession, shouldRetry keyRequest: AVContentKeyRequest,
                           reason retryReason: AVContentKeyRequest.RetryReason) -> Bool {
        print(retryReason)
        switch retryReason {
        case .timedOut, .receivedResponseWithExpiredLease, .receivedObsoleteContentKey:
            return true
        default:
            return false
        }
    }
    
    func handleStreamingContentKeyRequest(keyRequest: AVContentKeyRequest){
        guard let contentKeyIdentifier = keyRequest.identifier as? NSURL, let contentId = contentKeyIdentifier.host
            else {
                print("Failed to retrieve the assetID from the keyRequest!")
                return
        }
        self.requestContentKey(keyRequest, contentId) { keyResponse, error in
            if let keyResponse = keyResponse {
                print("success", keyResponse)
                keyRequest.processContentKeyResponse(keyResponse)
            } else {
                keyRequest.processContentKeyResponseError(error!)
            }
        }
            
    }
    
    func requestContentKey(_ keyRequest: AVContentKeyRequest, _ contentId: String, completion: @escaping (AVContentKeyResponse?, Error?) -> Void) {
        let contentIdData = contentId.data(using: .utf8)

        do {
            let certificateData = try getFairplayCertificateData()
            keyRequest.makeStreamingContentKeyRequestData(forApp: certificateData, contentIdentifier: contentIdData, options: [AVAssetResourceLoadingRequestStreamingContentKeyRequestRequiresPersistentKey: true as AnyObject]) { spcData, spcError in

                guard let spcData = spcData else {
                    completion(nil, DRMError.noSPCFound(underlyingError: spcError))
                    return
                }

                self.requestContentKeyFromKeySecurityModule(spcData: spcData, assetId: contentId) { data in
                    guard let data = data else {
                        completion(nil, DRMError.invalidKeyResponse)
                        return
                    }

                    let keyResponse = AVContentKeyResponse(fairPlayStreamingKeyResponseData: data)
                    completion(keyResponse, nil)
                }
            }
        } catch {
            completion(nil, DRMError.certificateError)
        }
    }
    
    func getFairplayCertificateData() throws -> Data {
        guard let url = URL(string: Constants.FAIRPLAY_CERTIFICATE_URL),
              let data = try? Data(contentsOf: url) else {
            throw DRMError.certificateError
        }
        return data
    }
    
    func requestContentKeyFromKeySecurityModule(spcData: Data, assetId: String, completion: @escaping(Data?) -> Void)  {
        let parameters = ["spc": spcData.base64EncodedString(), "assetId" : assetId] as [String : Any]
        guard let request = self.getLicenseKeyRequest(licenseURL: licenseURL, parameters: parameters) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else {
                completion(nil)
                return
            }
            if data != nil{
                print(String(decoding: data!, as: UTF8.self))
            }
            completion(data)
        }.resume()
    }
    
    func getLicenseKeyRequest(licenseURL: String, parameters: [String: Any]) -> URLRequest? {
        guard let url = URL(string: licenseURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return nil
        }
        return request
    }
}


