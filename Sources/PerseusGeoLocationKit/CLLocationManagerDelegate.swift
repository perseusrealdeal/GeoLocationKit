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

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        PerseusLogger.message("[\(type(of: self))].\(#function)")

        notificationCenter.post(name: .locationDealerStatusChangedNotification, object: status)
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        PerseusLogger.message("[\(type(of: self))].\(#function)")

        currentLocationDealOnly = false
        locationManager.stopUpdatingLocation()

        let result: LocationDealerError = .failedRequest(error.localizedDescription)

        notificationCenter.post(name: .locationDealerErrorNotification, object: result)
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        PerseusLogger.message("[\(type(of: self))].\(#function)")

        guard !currentLocationDealOnly else {

            currentLocationDealOnly = false
            locationManager.stopUpdatingLocation()

            let result: Result<CLLocation, LocationDealerError> =
                locations.first != nil ?
                    .success(locations.first!) :
                    .failure(.receivedEmptyLocationData)

            notificationCenter.post(name: .locationDealerCurrentNotification, object: result)
            return
        }

        let result: Result<[CLLocation], LocationDealerError> =
            !locations.isEmpty ? .success(locations) : .failure(.receivedEmptyLocationData)

        notificationCenter.post(name: .locationDealerUpdatesNotification, object: result)
    }
}
