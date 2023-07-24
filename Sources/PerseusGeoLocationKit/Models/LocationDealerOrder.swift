//
//  LocationDealerOrder.swift
//  PerseusGeoLocationKit
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 Mikhail Zhigulin of Novosibirsk.
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import Foundation

public enum LocationDealerOrder: CustomStringConvertible {

    public var description: String {
        switch self {
        case .none: // There should be no location notifying activity.
            return "None"
        case .currentLocation:
            return "Current Location"
        case .locationUpdates:
            return "Location Updates"
        case .authorization: // Used only to invoke Current Location Diolog on macOS.
            return "Authorization"
        }
    }

    case none
    case currentLocation
    case locationUpdates
    case authorization
}
