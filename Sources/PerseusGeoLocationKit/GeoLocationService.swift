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
    var locationManager: LocationManagerProtocol
    #else
    private var locationManager: CLLocationManager
    #endif

    var authorizationStatus: CLAuthorizationStatus {
        return type(of: locationManager).authorizationStatus()
    }

    var locationServicesEnabled: Bool {
        return type(of: locationManager).locationServicesEnabled()
    }

    private(set) var currentLocationDealOnly: Bool = true

    // MARK: - Singletone constructor

    static let shared: PerseusLocationDealer = { return PerseusLocationDealer() }()

    private override init() {
        #if DEBUG
        print(">> [\(type(of: self))]." + #function)
        #endif

        self.locationManager = CLLocationManager()

        super.init()

        locationManager.desiredAccuracy = APPROPRIATE_ACCURACY.rawValue
        locationManager.delegate = self
    }

    // MARK: - Contract

    func askForCurrentLocation(accuracy:LocationAccuracy = APPROPRIATE_ACCURACY,
        _ actionIfNotAllowed: ((_ reason: ReasonNotAllowed) -> Void)? = nil) {
        #if DEBUG
        print(">> [\(type(of: self))]." + #function)
        #endif
    }

    #if os(iOS)
    func askForAuthorization(_ authorization: LocationAuthorization) {
        #if DEBUG
        print(">> [\(type(of: self))]." + #function)
        #endif
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
    }
}
