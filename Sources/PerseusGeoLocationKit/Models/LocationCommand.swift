//
//  LocationCommand.swift
//  PerseusGeoLocationKit
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 - 7533 Mikhail A. Zhigulin of Novosibirsk
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import Foundation

public enum LocationCommand: CustomStringConvertible {

    public var description: String {
        switch self {
        case .none: // There should be no location notifying activity.
            return "None"
        case .currentLocation:
            return "Current Location"
        case .locationUpdates:
            return "Location Updates"
        case .permission: // Used only to invoke Current Location Diolog on macOS.
            return "Permission"
        }
    }

    case none
    case currentLocation
    case locationUpdates
    case permission
}
