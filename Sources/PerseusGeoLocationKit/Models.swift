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

// MARK: - Data structures and functions used in library

public enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case failure(Error)
}

public struct LocationAccuracy: RawRepresentable, Equatable {
    public var rawValue: CLLocationAccuracy

    // The highest possible accuracy that uses additional sensor data.
    public static let bestForNavigation = LocationAccuracy(
        rawValue: kCLLocationAccuracyBestForNavigation)

    // The best level of accuracy available.
    public static let best = LocationAccuracy(
        rawValue: kCLLocationAccuracyBest)

    // Accurate to within ten meters of the desired target.
    public static let nearestTenMeters = LocationAccuracy(
        rawValue: kCLLocationAccuracyNearestTenMeters)

    // Accurate to within one hundred meters.
    public static let hundredMeters = LocationAccuracy(
        rawValue: kCLLocationAccuracyHundredMeters)

    // Accurate to the nearest kilometer.
    public static let kilometer = LocationAccuracy(
        rawValue: kCLLocationAccuracyKilometer)

    // Accurate to the nearest three kilometers.
    public static let threeKilometers = LocationAccuracy(
        rawValue: kCLLocationAccuracyThreeKilometers)

    public init(rawValue: CLLocationAccuracy) {
        self.rawValue = rawValue
    }
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
        case .authorizedWhenInUse: // iOS
            return "authorizedWhenInUse"
        }
    }
}

public enum LocationAuthorization: CustomStringConvertible {

    case whenInUse
    case always

    public var description: String {
        switch self {
        case .whenInUse:
            return "When-in-use"
        case .always:
            return "Always"
        }
    }
}

public enum LocationDealerPermit: CustomStringConvertible {
    /// Location service is neither restricted nor the app denided
    case notDetermined

    /// provide instructions for changing restrictions options in
    /// Settings > General > Restrictions
    case deniedForAllAndRestricted /// in case if location services turned off
    case restricted  /// in case if location services turned on

    /// provide instructions for enabling the Location Services switch in Settings > Privacy
    case deniedForAllApps /// in case if location services turned off but not restricted

    /// provide instructions for enabling services for the app in Settings > The App
    case deniedForTheApp /// in case if location services turned on but not restricted

    /// either authorizedAlways or authorizedWhenInUse
    case allowed

    public var description: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .deniedForAllAndRestricted:
            return "deniedForAllAndRestricted"
        case .restricted:
            return "restricted"
        case .deniedForAllApps:
            return "deniedForAllApps"
        case .deniedForTheApp:
            return "deniedForTheApp"
        case .allowed:
            return "allowed"
        }
    }
}

public enum LocationDealerOrder: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: // There should be no location notifing activity
            return "None"
        case .currentLocation:
            return "Current Location"
        case .locationUpdates:
            return "Location Updates"
        case .authorization: // Used only to invoke Current Location Diolog on macOS
            return "Authorization"
        }
    }

    case none
    case currentLocation
    case locationUpdates
    case authorization
}

public func getPermit(serviceEnabled: Bool,
                      status: CLAuthorizationStatus) -> LocationDealerPermit {

    if status == .notDetermined {
        return .notDetermined
    }

    if status == .denied {
        return serviceEnabled ? .deniedForTheApp : .deniedForAllApps
    }

    if status == .restricted {
        return serviceEnabled ? .restricted : .deniedForAllAndRestricted
    }

    return .allowed
}
