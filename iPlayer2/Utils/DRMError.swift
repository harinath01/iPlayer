//
//  DRMError.swift
//  iPlayer2
//
//  Created by Testpress on 06/05/23.
//

import Foundation

public enum DRMError: Error {
    case noURLFound
    case noSPCFound(underlyingError: Error?)
    case noContentIdFound
    case invalidKeyResponse
    case certificateError
}
