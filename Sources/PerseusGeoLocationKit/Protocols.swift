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

// MARK: - Protocols serves isolation purpose for unit testing

extension CLLocationManager: LocationManagerProtocol { }
extension NotificationCenter: NotificationCenterProtocol { }

protocol LocationManagerProtocol {
    var delegate: CLLocationManagerDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }

    static func authorizationStatus() -> CLAuthorizationStatus
    static func locationServicesEnabled() -> Bool

    func startUpdatingLocation()
    func stopUpdatingLocation()

    @available(iOS 9.3, macOS 10.14, *)
    func requestLocation()

    @available(iOS 9.3, macOS 10.15, *)
    func requestWhenInUseAuthorization()

    @available(iOS 9.3, macOS 10.15, *)
    func requestAlwaysAuthorization()
}

protocol NotificationCenterProtocol {
    func post(name aName: NSNotification.Name, object anObject: Any?)
}
