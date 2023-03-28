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

let APPROPRIATE_ACCURACY = LocationAccuracy.threeKilometers

extension Notification.Name {
    static let locationDealerNotification = Notification.Name("locationDealerNotification")
}

class PerseusLocationDealer: NSObject, CLLocationManagerDelegate {

    #if DEBUG
    var locationManager: LocationManagerProtocol!
    var notificationCenter: NotificationCenterProtocol!
    #else
    private(set) var locationManager: CLLocationManager
    private(set) var notificationCenter: NotificationCenter
    #endif

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

    private(set) var currentLocationDealOnly: Bool = false

    // MARK: - Singleton constructor

    static let shared: PerseusLocationDealer = { return PerseusLocationDealer() }()

    private override init() {

        self.locationManager = CLLocationManager()
        self.notificationCenter = NotificationCenter.default

        super.init()

        locationManager.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
        locationManager.delegate = self
    }

    // MARK: - Contract

    func askForCurrentLocation(accuracy: LocationAccuracy = APPROPRIATE_ACCURACY,
        _ actionIfNotAllowed: ((_ permit: LocationDealerPermit) -> Void)? = nil) {

        let permit = locationPermitHidden

        guard permit == .allowed else {
            actionIfNotAllowed?(permit)
            return
        }

        locationManager.stopUpdatingLocation()

        currentLocationDealOnly = true
        locationManager.desiredAccuracy = accuracy.rawValue

        locationManager.startUpdatingLocation()
    }

    #if os(iOS)
    func askForAuthorization(_ authorization: LocationAuthorization) {
        switch authorization {
        case .whenInUse:
            locationManager.requestWhenInUseAuthorization()
        case .always:
            locationManager.requestAlwaysAuthorization()
        }
    }
    #endif

    // MARK: - CLLocationManagerDelegate contract

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        #if DEBUG
        print(">> [\(type(of: self))]." + #function)
        #endif
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        #if DEBUG
        print(">> [\(type(of: self))]." + #function)
        #endif
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        #if DEBUG
        print(">> [\(type(of: self))]." + #function)
        #endif

        locationManager.stopUpdatingLocation()
    }
}
