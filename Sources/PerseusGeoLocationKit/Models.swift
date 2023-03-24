//
//  Models.swift
//  PerseusGeoLocationKit
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 Mikhail Zhigulin of Novosibirsk.
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import CoreLocation

struct LocationAccuracy: RawRepresentable, Equatable {
    var rawValue: CLLocationAccuracy

    // The highest possible accuracy that uses additional sensor data.
    static let bestForNavigation =
        LocationAccuracy(rawValue: kCLLocationAccuracyBestForNavigation)

    // The best level of accuracy available.
    static let best = LocationAccuracy(rawValue: kCLLocationAccuracyBest)

    // Accurate to within ten meters of the desired target.
    static let nearestTenMeters =
        LocationAccuracy(rawValue: kCLLocationAccuracyNearestTenMeters)

    // Accurate to within one hundred meters.
    static let hundredMeters = LocationAccuracy(rawValue: kCLLocationAccuracyHundredMeters)

    // Accurate to the nearest kilometer.
    static let kilometer = LocationAccuracy(rawValue: kCLLocationAccuracyKilometer)

    // Accurate to the nearest three kilometers.
    static let threeKilometers = LocationAccuracy(rawValue: kCLLocationAccuracyThreeKilometers)

}

extension CLAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorizedAlways:
            return "authorizedAlways"
        }
    }
}

enum LocationAuthorization: CustomStringConvertible {

    case whenInUse
    case always

    var description: String {
        switch self {
        case .whenInUse:
            return "When-in-use"
        case .always:
            return "Always"
        }
    }
}

enum AuthorizationStatus: CustomStringConvertible {
    /// Location service is neither restricted nor the app denided
    case notDetermined

    /// provide instructions for changing restrictions options in
    /// Settings > General > Restrictions
    case deniedForAllAndRestricted /// in case if location services turned off
    case restricted  /// in case if location services turned on

    /// provide instructions for enabling the Location Services switch in Settings > Privacy
    case deniedForAll /// in case if location services turned off but not restricted

    /// provide instructions for enabling services for the app in Settings > The App
    case deniedForTheApp /// in case if location services turned on but not restricted

    var description: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .deniedForAllAndRestricted:
            return "deniedForAllAndRestricted"
        case .restricted:
            return "restricted"
        case .deniedForAll:
            return "deniedForAll"
        case .deniedForTheApp:
            return "deniedForTheApp"
        }
    }
}
