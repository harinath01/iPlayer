//
//  PlaybackSpeed.swift
//  iPlayer2
//
//  Created by Testpress on 06/05/23.
//
import Foundation

enum PlaybackSpeed: String, CaseIterable {
    case verySlow = "0.5x"
    case slow = "0.75x"
    case normal = "Normal"
    case fast = "1.25x"
    case veryFast = "1.5x"
    case double = "2x"
    
    var value: Float {
        switch self {
        case .verySlow:
            return 0.5
        case .slow:
            return 0.75
        case .normal:
            return 1
        case .fast:
            return 1.25
        case .veryFast:
            return 1.5
        case .double:
            return 2
        }
    }
    
    var label: String {
        return self.rawValue
    }
}
