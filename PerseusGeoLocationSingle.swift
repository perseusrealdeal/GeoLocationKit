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

    // Internal Flags

    internal var currentLocationDealOnly: Bool = false

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
        accuracy: LocationAccuracy = APPROPRIATE_ACCURACY,
        _ actionIfNotAllowed: ((_ permit: LocationDealerPermit) -> Void)? = nil) {

        let permit = locationPermitHidden

        guard permit == .allowed else { actionIfNotAllowed?(permit); return }

        locationManager.stopUpdatingLocation()

        currentLocationDealOnly = true
        locationManager.desiredAccuracy = accuracy.rawValue

        locationManager.startUpdatingLocation()
    }

    #if os(iOS)
    public func askForAuthorization(_ authorization: LocationAuthorization) {
        switch authorization {
        case .whenInUse:
            locationManager.requestWhenInUseAuthorization()
        case .always:
            locationManager.requestAlwaysAuthorization()
        }
    }
    #endif

    public func askToStartUpdatingLocation(accuracy: LocationAccuracy = APPROPRIATE_ACCURACY) {
        currentLocationDealOnly = false
        locationManager.stopUpdatingLocation()

        locationManager.desiredAccuracy = accuracy.rawValue
        locationManager.startUpdatingLocation()
    }

    public func askToStopUpdatingLocation() {
        currentLocationDealOnly = false
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

        currentLocationDealOnly = false
        locationManager.stopUpdatingLocation()

        let result: LocationDealerError = .failedRequest(error.localizedDescription)

        notificationCenter.post(name: .locationDealerErrorNotification, object: result)
    }

    public func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {

        guard !currentLocationDealOnly else {

            currentLocationDealOnly = false
            locationManager.stopUpdatingLocation()

            let result: Result<CLLocation, LocationDealerError> =
                locations.first != nil ?
                    .success(locations.first!) :
                    .failure(.receivedEmptyLocationData)

            notificationCenter.post(name: .locationDealerCurrentNotification, object: result)
            return
        }

        let result: Result<[CLLocation], LocationDealerError> =
            !locations.isEmpty ? .success(locations) : .failure(.receivedEmptyLocationData)

        notificationCenter.post(name: .locationDealerUpdatesNotification, object: result)
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

#if os(iOS)
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
#endif

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
