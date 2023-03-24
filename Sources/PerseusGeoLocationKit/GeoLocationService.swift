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

extension Notification.Name {
    static let locationDealerNotification = Notification.Name("locationDealerNotification")
}

class PerseusLocationDealer: NSObject, CLLocationManagerDelegate {

    var appropriateAccuracy = LocationAccuracy.threeKilometers

    #if DEBUG
    var locationManager: LocationManagerProtocol
    #else
    private var locationManager: CLLocationManager
    #endif

    var authorizationStatus: AuthorizationStatus {

        let _ = type(of: locationManager).authorizationStatus()
        let _ = type(of: locationManager).locationServicesEnabled()

        return .notDetermined
    }

    // MARK: - Singletone constructor

    static let shared: PerseusLocationDealer = { return PerseusLocationDealer() }()

    private override init() {
        #if DEBUG
        print(">> [\(type(of: self))]." + #function)
        #endif

        self.locationManager = CLLocationManager()

        super.init()

        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
    }

    // MARK: - Contract

    func askForCurrentLocation(_ actionIfNotAllowed:
        ((_ status: AuthorizationStatus) -> Void)? = nil) {
        #if DEBUG
        print(">> [\(type(of: self))]." + #function)
        #endif
    }

    func askForAuthorization(_ authorization: LocationAuthorization) {
        #if DEBUG
        print(">> [\(type(of: self))]." + #function)
        #endif
    }

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
    }
}

protocol LocationManagerProtocol {
    var delegate: CLLocationManagerDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }

    func stopUpdatingLocation()
    func startUpdatingLocation()

    static func authorizationStatus() -> CLAuthorizationStatus
    static func locationServicesEnabled() -> Bool
}

extension CLLocationManager: LocationManagerProtocol { }
