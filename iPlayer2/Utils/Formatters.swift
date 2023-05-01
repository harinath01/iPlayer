//
//  Formaters.swift
//  iPlayer2
//
//  Created by Testpress on 01/05/23.
//

import Foundation

func formatDuration(_ durationInSeconds: Double) -> String? {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = .pad

    return formatter.string(from: durationInSeconds)
}
