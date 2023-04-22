//
//  GeoLocationService.swift
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

// Servants

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

#if DEBUG
    var locationManager: LocationManagerProtocol!
    var notificationCenter: NotificationCenterProtocol!

    internal func resetDefaults() { // used for keeping test room cleaned only
        currentLocationDealOnly = false
        if locationManager != nil {
            locationManager.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
        }
    }
#else
    private var locationManager: CLLocationManager
    private var notificationCenter: NotificationCenter
#endif

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

    internal var currentLocationDealOnly: Bool = false

    // MARK: - Singleton constructor

    public static let shared: PerseusLocationDealer = { return PerseusLocationDealer() }()

    private override init() {

        // log.turned = .off
        log.message("[\(PerseusLocationDealer.self)].\(#function)")

        self.locationManager = CLLocationManager()
        self.notificationCenter = NotificationCenter.default

        super.init()

        locationManager.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
        locationManager.delegate = self
    }

    // MARK: - Contract

    public func askForCurrentLocation(
        accuracy: LocationAccuracy = APPROPRIATE_ACCURACY) throws {

            log.message("[\(type(of: self))].\(#function)")

            let permit = locationPermitHidden
            guard permit == .allowed else { throw LocationDealerError.needsPermission(permit) }

            locationManager.stopUpdatingLocation()

            currentLocationDealOnly = true
            locationManager.desiredAccuracy = accuracy.rawValue

            if #available(iOS 9.3, macOS 10.14, *) {
                locationManager.requestLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
        }

    public func askForAuthorization(_ authorization: LocationAuthorization = .whenInUse,
        _ actionIfdetermined: ((_ permit: LocationDealerPermit) -> Void)? = nil) {

        log.message("[\(type(of: self))].\(#function)")

        let permit = locationPermitHidden
        guard permit == .notDetermined else { actionIfdetermined?(permit); return }

        if #available(iOS 9.3, macOS 10.15, *) {
            switch authorization {
            case .whenInUse:
                locationManager.requestWhenInUseAuthorization()
            case .always:
                locationManager.requestAlwaysAuthorization()
            }
        } else {
            locationManager.stopUpdatingLocation()

            currentLocationDealOnly = true
            locationManager.startUpdatingLocation()

            currentLocationDealOnly = false
            locationManager.stopUpdatingLocation()
        }
    }

    public func askToStartUpdatingLocation(accuracy: LocationAccuracy = APPROPRIATE_ACCURACY) {

        log.message("[\(type(of: self))].\(#function)")

        currentLocationDealOnly = false
        locationManager.stopUpdatingLocation()

        locationManager.desiredAccuracy = accuracy.rawValue
        locationManager.startUpdatingLocation()
    }

    public func askToStopUpdatingLocation() {

        log.message("[\(type(of: self))].\(#function)")

        currentLocationDealOnly = false
        locationManager.stopUpdatingLocation()
    }
}
