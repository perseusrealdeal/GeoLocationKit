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

// Debug servants

#if DEBUG
let printMessagesInConsole = false
#endif

// MARK: - Default values

let APPROPRIATE_ACCURACY = LocationAccuracy.threeKilometers

// MARK: - Notifications

extension Notification.Name {
    static let locationDealerCurrentNotification =
        Notification.Name("locationDealerCurrentNotification")
    static let locationDealerUpdatesNotification =
        Notification.Name("locationDealerUpdatesNotification")
    static let locationDealerErrorNotification =
        Notification.Name("locationDealerErrorNotification")
    static let locationDealerStatusChangedNotification =
        Notification.Name("locationDealerStatusChangedNotification")
}

// MARK: - Errors

enum LocationDealerError: Error, Equatable {
    case receivedEmptyLocationData
    case failedRequest(String)
}

// MARK: - Business class

class PerseusLocationDealer: NSObject {

    // MARK: - Difficult Dependencies

    #if DEBUG
    var locationManager: LocationManagerProtocol!
    var notificationCenter: NotificationCenterProtocol!

    internal func resetDefaults() { // used for keeping test room cleaned only
        currentLocationDealOnly = false
        if let _ = locationManager {
            locationManager.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
        }
    }
    #else
    private var locationManager: CLLocationManager
    private var notificationCenter: NotificationCenter
    #endif

    // MARK: - Calculated Properties

    var desiredAccuracy: CLLocationAccuracy { return locationManager.desiredAccuracy }

    var authorizationStatus: CLAuthorizationStatus { return authorizationStatusHidden }
    private var authorizationStatusHidden: CLAuthorizationStatus {
        return type(of: locationManager).authorizationStatus()
    }

    var locationServicesEnabled: Bool { return locationServicesEnabledHidden }
    private var locationServicesEnabledHidden: Bool {
        return type(of: locationManager).locationServicesEnabled()
    }

    var locationPermit: LocationDealerPermit { return locationPermitHidden }
    private var locationPermitHidden: LocationDealerPermit {
        return getPermit(serviceEnabled: locationServicesEnabledHidden,
                         status: authorizationStatusHidden)
    }

    // Internal Flags

    internal var currentLocationDealOnly: Bool = false

    // MARK: - Singleton constructor

    static let shared: PerseusLocationDealer = { return PerseusLocationDealer() }()

    private override init() {
        #if DEBUG
        if printMessagesInConsole { print(">> [\(type(of: self))]." + #function) }
        #endif

        self.locationManager = CLLocationManager()
        self.notificationCenter = NotificationCenter.default

        super.init()

        locationManager.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
        locationManager.delegate = self
    }

    // MARK: - Contract

    func askForCurrentLocation(accuracy: LocationAccuracy = APPROPRIATE_ACCURACY,
        _ actionIfNotAllowed: ((_ permit: LocationDealerPermit) -> Void)? = nil) {
        #if DEBUG
        if printMessagesInConsole { print(">> [\(type(of: self))]." + #function) }
        #endif

        let permit = locationPermitHidden

        guard permit == .allowed else { actionIfNotAllowed?(permit); return }

        locationManager.stopUpdatingLocation()

        currentLocationDealOnly = true
        locationManager.desiredAccuracy = accuracy.rawValue

        locationManager.startUpdatingLocation()
    }

    #if os(iOS)
    func askForAuthorization(_ authorization: LocationAuthorization) {
        #if DEBUG
        if printMessagesInConsole { print(">> [\(type(of: self))]." + #function) }
        #endif

        switch authorization {
        case .whenInUse:
            locationManager.requestWhenInUseAuthorization()
        case .always:
            locationManager.requestAlwaysAuthorization()
        }
    }
    #endif

    func askToStartUpdatingLocation() {
        #if DEBUG
        if printMessagesInConsole { print(">> [\(type(of: self))]." + #function) }
        #endif

        currentLocationDealOnly = false
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }

    func askToStopUpdatingLocation() {
        #if DEBUG
        if printMessagesInConsole { print(">> [\(type(of: self))]." + #function) }
        #endif

        currentLocationDealOnly = false
        locationManager.stopUpdatingLocation()
    }
}
