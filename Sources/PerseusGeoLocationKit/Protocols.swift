//
//  Protocols.swift
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

extension CLLocationManager: LocationManagerProtocol { }

protocol LocationManagerProtocol {
    var delegate: CLLocationManagerDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }

    static func authorizationStatus() -> CLAuthorizationStatus
    static func locationServicesEnabled() -> Bool

    func stopUpdatingLocation()
    func startUpdatingLocation()

    #if os(iOS)
    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    #endif
}
