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

public class PerseusLocationDealer: NSObject {

    // MARK: - Difficult Dependencies

#if DEBUG
    var locationManager: LocationManagerProtocol!
    var notificationCenter: NotificationCenterProtocol!

    internal func resetDefaults() { // Used for keeping test room cleaned only.
        order = .none
        if locationManager != nil {
            locationManager.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
        }
    }
#else
    public let locationManager: CLLocationManager
    public let notificationCenter: NotificationCenter
#endif

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

        log.level = .info
        // log.turned = .off
        log.message("[\(PerseusLocationDealer.self)].\(#function)")

        locationManager = CLLocationManager()
        notificationCenter = NotificationCenter.default

        super.init()

        // These two statements are out of unit tests actually... refactoring maybe later.
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

        log.message("[\(type(of: self))].\(#function) with accuracy:\(accuracy)", .info)

        order = .locationUpdates
        locationManager.desiredAccuracy = accuracy.rawValue
        locationManager.startUpdatingLocation()

        let ac = locationManager.desiredAccuracy
        log.message("[\(type(of: self))].\(#function) with accuracy:\(ac)", .info)
    }

    public func askToStopUpdatingLocation() {

        log.message("[\(type(of: self))].\(#function)", .info)

        locationManager.stopUpdatingLocation(); order = .none
    }
}
