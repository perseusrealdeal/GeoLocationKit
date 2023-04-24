//
//  CLLocationManagerDelegate.swift
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

extension PerseusLocationDealer: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {

        log.message("[\(type(of: self))].\(#function) status .\(status)", .info)

        notificationCenter.post(name: .locationDealerStatusChangedNotification, object: status)
    }

    public func locationManager(_ manager: CLLocationManager,
                                didFailWithError error: Error) {

        log.message("[\(type(of: self))].\(#function)", .info)

        locationManager.stopUpdatingLocation()

        guard order != .authorization else { order = .none; return }

        order = .none

        let result: LocationDealerError = .failedRequest(error.localizedDescription)
        notificationCenter.post(name: .locationDealerErrorNotification, object: result)
    }

    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {

        log.message("[\(type(of: self))].\(#function)", .info)

        if order == .none {
            log.message("[\(type(of: self))].\(#function) — Locations for no order!", .error)
            locationManager.stopUpdatingLocation()
            return
        }

        if order == .authorization {
            log.message("[\(type(of: self))].\(#function) — Authorization order!")
            locationManager.stopUpdatingLocation(); order = .none
            return
        }

        if order == .currentLocation {

            locationManager.stopUpdatingLocation(); order = .none

            let result: Result<PerseusLocation, LocationDealerError> = locations.first == nil ?
                .failure(.receivedEmptyLocationData) :
                .success(locations.first!.perseus)

            notificationCenter.post(name: .locationDealerCurrentNotification, object: result)

        } else if order == .locationUpdates {

            let perseusLocations = locations.map { PerseusLocation($0) }

            let result: Result<[PerseusLocation], LocationDealerError> = locations.isEmpty ?
                .failure(.receivedEmptyLocationData) : .success(perseusLocations)

            if locations.isEmpty {
                log.message("[\(type(of: self))].\(#function) — No locations!", .error)
                order = .none; locationManager.stopUpdatingLocation()
            }

            notificationCenter.post(name: .locationDealerUpdatesNotification, object: result)
        }
    }
}
