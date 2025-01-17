//
//  LocationAgent.swift
//  PerseusGeoLocationKit
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 - 7533 Mikhail A. Zhigulin of Novosibirsk
//  Copyright © 7533 PerseusRealDeal
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import CoreLocation

public class LocationAgent: NSObject {

    // MARK: - Difficult Dependencies

    #if DEBUG
    var locationManager: LocationManagerProtocol!
    var notificationCenter: NotificationCenterProtocol!

    internal func resetDefaults() { // Used for keeping test room cleaned only.
        order = .none
        locationManager?.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
    }
    #else
    public let locationManager: CLLocationManager
    public let notificationCenter: NotificationCenter
    #endif

    // MARK: - Calculated Properties

    public var locationPermit: LocationPermit { return locationPermitHidden }

    private var locationPermitHidden: LocationPermit {
        let enabled = type(of: locationManager).locationServicesEnabled()
        let status = type(of: locationManager).authorizationStatus()

        return getPermit(serviceEnabled: enabled, status: status)
    }

    // MARK: - Internal Flags

    internal var order: LocationCommand = .none

    // MARK: - Singleton constructor

    public static let shared: LocationAgent = { return LocationAgent() }()

    private override init() {
        // log.level = .info
        // log.turned = .off

        log.message("[\(LocationAgent.self)].\(#function)", .info)

        locationManager = CLLocationManager()
        notificationCenter = NotificationCenter.default

        super.init()

        locationManager.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
        locationManager.delegate = self
    }

    // MARK: - Contract

    public func requestPermission(_ authorization: LocationPermission = .always,
                                  _ actionIfdetermined: ((_ permit: LocationPermit)
                                                         -> Void)? = nil) {
        log.message("[\(type(of: self))].\(#function)")

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
        order = .permission
        locationManager.startUpdatingLocation()
#endif
    }

    public func requestCurrentLocation(with accuracy: LocationAccuracy = APPROPRIATE_ACCURACY)
    throws {
        let permit = locationPermitHidden
        log.message("[\(type(of: self))].\(#function)")

        guard permit == .allowed else {
            log.message("[\(type(of: self))].\(#function) — permit .\(permit)", .error)
            throw LocationError.needsPermission(permit)
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

    public func startUpdatingLocation(accuracy: LocationAccuracy = APPROPRIATE_ACCURACY) {
        log.message("[\(type(of: self))].\(#function)")
        order = .locationUpdates

        locationManager.desiredAccuracy = accuracy.rawValue
        locationManager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        log.message("[\(type(of: self))].\(#function)")

        locationManager.stopUpdatingLocation()
        order = .none
    }
}
