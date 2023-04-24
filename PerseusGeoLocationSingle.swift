//
//  PerseusGeoLocationSingle.swift
//  Version: 0.1.0
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 Mikhail Zhigulin of Novosibirsk.
//  All rights reserved.
//
//
//  MIT License
//
//  Copyright © 7531 Mikhail Zhigulin of Novosibirsk
//
//  The year starts from the creation of the world according to a Slavic calendar.
//  September, the 1st of Slavic year.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
// swiftlint:disable file_length
//

import CoreLocation

// MARK: - Default values

public let APPROPRIATE_ACCURACY = LocationAccuracy.threeKilometers

// MARK: - Notifications

extension Notification.Name {
    public static let locationDealerCurrentNotification =
        Notification.Name("locationDealerCurrentNotification")
    public static let locationDealerUpdatesNotification =
        Notification.Name("locationDealerUpdatesNotification")
    public static let locationDealerErrorNotification =
        Notification.Name("locationDealerErrorNotification")
    public static let locationDealerStatusChangedNotification =
        Notification.Name("locationDealerStatusChangedNotification")
}

// MARK: - Errors

public enum LocationDealerError: Error, Equatable {
    case needsPermission(LocationDealerPermit)
    case receivedEmptyLocationData
    case failedRequest(String)
}

// MARK: - Business class

public class PerseusLocationDealer: NSObject {

    // MARK: - Difficult Dependencies

    private var locationManager: CLLocationManager
    private var notificationCenter: NotificationCenter

    // MARK: - Calculated Properties

    public var desiredAccuracy: CLLocationAccuracy { return locationManager.desiredAccuracy }

    public var authorizationStatus: CLAuthorizationStatus { return authorizationStatusHidden }
    private var authorizationStatusHidden: CLAuthorizationStatus {
        return type(of: locationManager).authorizationStatus()
    }

    public var locationServicesEnabled: Bool { return locationServicesEnabledHidden }
    private var locationServicesEnabledHidden: Bool {
        return type(of: locationManager).locationServicesEnabled()
    }

    public var locationPermit: LocationDealerPermit { return locationPermitHidden }
    private var locationPermitHidden: LocationDealerPermit {
        return getPermit(serviceEnabled: locationServicesEnabledHidden,
                         status: authorizationStatusHidden)
    }

    // MARK: - Internal Flags

    internal var order: LocationDealerOrder = .none

    // MARK: - Singleton constructor

    public static let shared: PerseusLocationDealer = { return PerseusLocationDealer() }()

    private override init() {

        self.locationManager = CLLocationManager()
        self.notificationCenter = NotificationCenter.default

        super.init()

        locationManager.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
        locationManager.delegate = self
    }

    // MARK: - Contract

    public func askForCurrentLocation(
        with accuracy: LocationAccuracy = APPROPRIATE_ACCURACY) throws {

        let permit = locationPermitHidden
        guard permit == .allowed else {
            throw LocationDealerError.needsPermission(permit)
        }

        locationManager.stopUpdatingLocation()

        order = .currentLocation
        locationManager.desiredAccuracy = accuracy.rawValue

#if os(iOS)
        locationManager.requestLocation()
#elseif os(macOS)
        locationManager.startUpdatingLocation()
#endif
    }

    public func askForAuthorization(
        _ authorization: LocationAuthorization = .always,
        _ actionIfdetermined: ((_ permit: LocationDealerPermit) -> Void)? = nil) {

        let permit = locationPermitHidden
        guard permit == .notDetermined else {
            actionIfdetermined?(permit)
            return
        }

#if os(iOS)
        order = .none
        switch authorization {
        case .whenInUse:
            locationManager.requestWhenInUseAuthorization()
        case .always:
            locationManager.requestAlwaysAuthorization()
        }
#elseif os(macOS)
        order = .authorization
        locationManager.startUpdatingLocation()
#endif
    }

    public func askToStartUpdatingLocation(accuracy: LocationAccuracy = APPROPRIATE_ACCURACY) {
        order = .locationUpdates
        locationManager.desiredAccuracy = accuracy.rawValue
        locationManager.startUpdatingLocation()
    }

    public func askToStopUpdatingLocation() {
        order = .none
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension PerseusLocationDealer: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {

        notificationCenter.post(name: .locationDealerStatusChangedNotification, object: status)
    }

    public func locationManager(_ manager: CLLocationManager,
                                didFailWithError error: Error) {

        order = .none; locationManager.stopUpdatingLocation()

        let result: LocationDealerError = .failedRequest(error.localizedDescription)
        notificationCenter.post(name: .locationDealerErrorNotification, object: result)
    }

    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {

        if order == .none {
            locationManager.stopUpdatingLocation()
            return
        }

        if order == .authorization {
            locationManager.stopUpdatingLocation(); order = .none
            return
        }

        if order == .currentLocation {

            locationManager.stopUpdatingLocation(); order = .none

            let result: Result<CLLocation, LocationDealerError> = locations.first == nil ?
                .failure(.receivedEmptyLocationData) : .success(locations.first!)

            notificationCenter.post(name: .locationDealerCurrentNotification, object: result)

        } else if order == .locationUpdates {

            let result: Result<[CLLocation], LocationDealerError> = locations.isEmpty ?
                .failure(.receivedEmptyLocationData) : .success(locations)

            if locations.isEmpty { order = .none; locationManager.stopUpdatingLocation() }

            notificationCenter.post(name: .locationDealerUpdatesNotification, object: result)
        }
    }
}

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
        case .none: // There should be no location notifying activity
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
