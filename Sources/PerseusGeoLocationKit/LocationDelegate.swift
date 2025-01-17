//
//  LocationDelegate.swift
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

extension LocationAgent: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        log.message("[\(type(of: self))].\(#function) status .\(status)")

        notificationCenter.post(name: .locationDealerStatusChangedNotification, object: status)
    }

    public func locationManager(_ manager: CLLocationManager,
                                didFailWithError error: Error) {
        log.message("[\(type(of: self))].\(#function) \(error.localizedDescription)", .error)

        locationManager.stopUpdatingLocation()

        // ISSUE: macOS (new releases) generates an error on startUpdatingLocation()
        // if a user makes no decision immediately, 2 or 3 sec, with Current Location Diolog.
        // FIXED: Restrict error notifiying in case when a user tries to give a permission
        // so that there is no difference in Current Location Diolog behavior in either early
        // or new macOS releases.

        #if os(macOS)
        if order == .permission, locationPermit == .notDetermined { return }
        #endif

        order = .none

        let result: LocationError = .failedRequest(error.localizedDescription)

        notificationCenter.post(name: .locationDealerErrorNotification, object: result)
    }

    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        log.message("[\(type(of: self))].\(#function)")

        if order == .none {
            log.message("[\(type(of: self))].\(#function) — Locations for no order!", .notice)
            locationManager.stopUpdatingLocation()
            return
        }

        if order == .permission {
            log.message("[\(type(of: self))].\(#function) — Authorization order!", .notice)
            locationManager.stopUpdatingLocation()
            order = .none
            return
        }

        if order == .currentLocation {

            locationManager.stopUpdatingLocation()
            order = .none

            let result: Result<PerseusLocation, LocationError> = locations.first == nil ?
                .failure(.receivedEmptyLocationData) :
                .success(locations.first!.perseus)

            notificationCenter.post(name: .locationDealerCurrentNotification, object: result)

        } else if order == .locationUpdates {

            if locations.isEmpty {
                log.message("[\(type(of: self))].\(#function) — No locations!", .notice)
                locationManager.stopUpdatingLocation()
                order = .none
            }

            let result: Result<[PerseusLocation], LocationError> = locations.isEmpty ?
                .failure(.receivedEmptyLocationData) : .success(locations.map { $0.perseus })

            notificationCenter.post(name: .locationDealerUpdatesNotification, object: result)
        }
    }
}
