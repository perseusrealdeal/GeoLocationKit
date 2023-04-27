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
        order = .none
        if locationManager != nil {
            locationManager.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
        }
    }
#else
    private var locationManager: CLLocationManager
    private var notificationCenter: NotificationCenter

    public var locationManagerInUse: CLLocationManager { return locationManager }
    public var notificationCenterInUse: NotificationCenter { return notificationCenter }
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

    internal var order: LocationDealerOrder = .none

    // MARK: - Singleton constructor

    public static let shared: PerseusLocationDealer = { return PerseusLocationDealer() }()

    private override init() {

        // log.level = .info
        // log.turned = .off
        log.message("[\(PerseusLocationDealer.self)].\(#function)")

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
        log.message("[\(type(of: self))].\(#function)", .info)

        guard permit == .allowed else {
            log.message("[\(type(of: self))].\(#function) — permit .\(permit)", .error)
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

        log.message("[\(type(of: self))].\(#function)", .info)

        let permit = locationPermitHidden
        guard permit == .notDetermined else {
            log.message("[\(type(of: self))].\(#function) — permit .\(permit)", .error)
            actionIfdetermined?(permit)
            return
        }

#if os(iOS)
        switch authorization {
        case .whenInUse:
            locationManager.requestWhenInUseAuthorization()
        case .always:
            locationManager.requestAlwaysAuthorization()
        }

        order = .none
#elseif os(macOS)
        order = .authorization
        locationManager.startUpdatingLocation()
#endif
    }

    public func askToStartUpdatingLocation(accuracy: LocationAccuracy = APPROPRIATE_ACCURACY) {

        log.message("[\(type(of: self))].\(#function)", .info)

        order = .locationUpdates
        locationManager.desiredAccuracy = accuracy.rawValue
        locationManager.startUpdatingLocation()
    }

    public func askToStopUpdatingLocation() {

        log.message("[\(type(of: self))].\(#function)", .info)

        locationManager.stopUpdatingLocation(); order = .none
    }
}
