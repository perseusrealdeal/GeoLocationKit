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

// MARK: - Constants

public let APPROPRIATE_ACCURACY = LocationAccuracy.threeKilometers

// MARK: - Notifications

extension Notification.Name {

    // Current Location
    public static let locationDealerCurrentNotification =
    Notification.Name("locationDealerCurrentNotification")

    // Location Changing Updates
    public static let locationDealerUpdatesNotification =
    Notification.Name("locationDealerUpdatesNotification")

    // Error
    public static let locationDealerErrorNotification =
    Notification.Name("locationDealerErrorNotification")

    // Location Service Status
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

    public let locationManager: CLLocationManager
    public let notificationCenter: NotificationCenter

    // MARK: - Calculated Properties

    public var locationPermit: LocationDealerPermit { return locationPermitHidden }

    private var locationPermitHidden: LocationDealerPermit {
        let enabled = type(of: locationManager).locationServicesEnabled()
        let status = type(of: locationManager).authorizationStatus()

        return getPermit(serviceEnabled: enabled, status: status)
    }

    // MARK: - Internal Flags

    internal var order: LocationDealerOrder = .none

    // MARK: - Singleton constructor

    public static let shared: PerseusLocationDealer = { return PerseusLocationDealer() }()

    private override init() {

        locationManager = CLLocationManager()
        notificationCenter = NotificationCenter.default

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

        locationManager.stopUpdatingLocation()

        // ISSUE: macOS (new releases) generates an error on startUpdatingLocation()
        // if a user makes no decision immediately, 2 or 3 sec, with Current Location Diolog.
        // FIXED: Restrict error notifiying in case when a user tries to give a permission
        // so that there is no difference in Current Location Diolog behavior in either early
        // or new macOS releases.
#if os(macOS)
        if order == .authorization, locationPermit == .notDetermined { return }
#endif
        order = .none

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

            let result: Result<PerseusLocation, LocationDealerError> = locations.first == nil ?
                .failure(.receivedEmptyLocationData) :
                .success(locations.first!.perseus)

            notificationCenter.post(name: .locationDealerCurrentNotification, object: result)

        } else if order == .locationUpdates {

            if locations.isEmpty { locationManager.stopUpdatingLocation(); order = .none }

            let result: Result<[PerseusLocation], LocationDealerError> = locations.isEmpty ?
                .failure(.receivedEmptyLocationData) : .success(locations.map { $0.perseus })

            notificationCenter.post(name: .locationDealerUpdatesNotification, object: result)
        }
    }
}

// MARK: - Data structures and functions used within business class

public enum Result<Value, Error: Swift.Error> {

    case success(Value)
    case failure(Error)
}

public struct LocationAccuracy: RawRepresentable, Equatable {

    // MARK: - RawRepresentable

    public var rawValue: CLLocationAccuracy

    // MARK: - Values

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

    // MARK: - Initializer

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
        case .authorizedWhenInUse: // iOS only.
            return "authorizedWhenInUse"
        }
    }
}

public enum LocationAuthorization: CustomStringConvertible {

    public var description: String {
        switch self {
        case .whenInUse:
            return "When-in-use"
        case .always:
            return "Always"
        }
    }

    case whenInUse
    case always
}

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

extension CLLocation { public var perseus: PerseusLocation { return PerseusLocation(self) } }

extension Double {

    public enum DecimalPlaces: Double {
        case two  = 100.0
        case four = 10000.0
    }

    public func cut(_ off: DecimalPlaces) -> Double {
        return (self * off.rawValue).rounded(self > 0 ? .down : .up) / off.rawValue
    }
}

public struct PerseusLocation: CustomStringConvertible, Equatable {

    public var description: String {

        let locationTwo = "[\(latitude.cut(.two)), \(longitude.cut(.two))]"

        let latitudeFour = "latitude = \(latitude.cut(.four))"
        let longitudeFour = "longitude = \(longitude.cut(.four))"

        return locationTwo + ": " + latitudeFour + ", " + longitudeFour
    }

    // MARK: - Location Data, As Is

    public let location: CLLocation

    public var latitude: Double { return location.coordinate.latitude }
    public var longitude: Double { return location.coordinate.longitude }

    // MARK: - Initializer

    public init(_ location: CLLocation) {
        self.location = location
    }

    // MARK: - Equatable

    public static func == (lhs: PerseusLocation, rhs: PerseusLocation) -> Bool {
        return lhs.location == rhs.location
    }
}

public enum LocationDealerPermit: CustomStringConvertible {

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

    // Location service is neither restricted nor the app denided.
    case notDetermined

    // Go to Settings > General > Restrictions.
    // In case if location services turned off and the app restricted.
    case deniedForAllAndRestricted
    // In case if location services turned on and the app restricted.
    case restricted

    // Go to Settings > Privacy.
    // In case if location services turned off but the app not restricted.
    case deniedForAllApps

    // Go to Settings > The App.
    // In case if location services turned on but the app not restricted.
    case deniedForTheApp

    // Either authorizedAlways or authorizedWhenInUse.
    case allowed
}

public func getPermit(serviceEnabled: Bool,
                      status: CLAuthorizationStatus) -> LocationDealerPermit {

    // There is no status .notDetermined with serviceEnabled false.
    if status == .notDetermined { // So, serviceEnabled takes true.
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
