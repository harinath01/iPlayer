//
//  Constants.swift
//  iPlayer2
//
//  Created by Testpress on 29/04/23.
//
struct Constants{
    struct Videos {
        static let DRM_PROTECTED_VIDEO1 = "https://d384padtbeqfgy.cloudfront.net/transcoded/68PAFnYTjSU/video.m3u8"
        static let DRM_PROTECTED_VIDEO2 = "https://d384padtbeqfgy.cloudfront.net/transcoded/8eaHZjXt6km/video.m3u8"
        static let DRM_PROTECTED_VIDEO3 = "https://d384padtbeqfgy.cloudfront.net/transcoded/4tnUXUKgsSr/video.m3u8"
        static let NON_DRM_PROTECTED_VIDEO = "https://d384padtbeqfgy.cloudfront.net/transcoded/AeDsCzqB5Td/video.m3u8"
    }
    
    static let FAIRPLAY_CERTIFICATE_URL = "https://app.tpstreams.com/static/fairplay.cer"
    static let DRM_LICENSE_URL1 = "https://app.tpstreams.com/api/v1/6eafqn/assets/68PAFnYTjSU/drm_license/?access_token=5f3ded52-ace8-487e-809c-10de895872d6&drm_type=fairplay"
    static let DRM_LICENSE_URL2 = "https://app.tpstreams.com/api/v1/6eafqn/assets/8eaHZjXt6km/drm_license/?access_token=16b608ba-9979-45a0-94fb-b27c1a86b3c1&drm_type=fairplay"
    static let DRM_LICENSE_URL3 = "https://app.tpstreams.com/api/v1/6eafqn/assets/4tnUXUKgsSr/drm_license/?access_token=a486e0a5-f613-40c7-9e6d-5298d135c154&drm_type=fairplay"
}

