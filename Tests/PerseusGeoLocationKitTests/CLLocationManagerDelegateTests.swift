//
//  CLLocationManagerDelegateTests.swift
//  PerseusGeoLocationKitTests
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 Mikhail Zhigulin of Novosibirsk.
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import XCTest
import CoreLocation
@testable import PerseusGeoLocationKit

extension PerseusLocationDealerTests {

    func test_didChangeAuthorization() {

        // arrange, act

        mockLM.delegate?.locationManager?(CLLocationManager(),
                                          didChangeAuthorization: .restricted)

        // assert

        mockNC.verify_post_didChangeAuthorization(
            name: .locationDealerStatusChangedNotification,
            object: CLAuthorizationStatus.restricted)
    }

    func test_didFailWithError() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        let error = LocationDealerError.failedRequest("")
        let result: LocationDealerError = .failedRequest(error.localizedDescription)

        // act

        try? sut.askForCurrentLocation()
        mockLM.delegate?.locationManager?(CLLocationManager(), didFailWithError: error)

        // assert

        XCTAssertFalse(sut.currentLocationDealOnly)

        mockLM.verify_stopUpdatingLocation_CalledTwice()
#if os(iOS)
        mockLM.verify_requestLocation_CalledOnce()
#elseif os(macOS)
        mockLM.verify_startUpdatingLocation_CalledOnce()
#endif

        mockNC.verify_post_locationDealerNotification_withError(
            name: .locationDealerErrorNotification, object: result)
    }

    func test_didUpdateLocations_currentLocationDealOnlyTrue_receivedEmptyLocationData() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        let error = LocationDealerError.receivedEmptyLocationData
        let result: Result<CLLocation, LocationDealerError> = .failure(error)
        let locations = [CLLocation]()

        // act

        try? sut.askForCurrentLocation()
        mockLM.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: locations)

        // assert

        XCTAssertFalse(sut.currentLocationDealOnly)

        mockLM.verify_stopUpdatingLocation_CalledTwice()
#if os(iOS)
        mockLM.verify_requestLocation_CalledOnce()
#elseif os(macOS)
        mockLM.verify_startUpdatingLocation_CalledOnce()
#endif

        mockNC.verify_post_locationDealerNotification_withError(
            name: .locationDealerCurrentNotification, object: result)
    }

    func test_didUpdateLocations_currentLocationDealOnlyTrue_receivedCurrentLocation() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        let coord = CLLocationCoordinate2D(latitude: 87.90, longitude: 34.83)
        let firstLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

        let locations = [firstLocation, CLLocation(latitude: 34.78, longitude: 34.83)]
        let result: Result<CLLocation, LocationDealerError> = .success(firstLocation)

        // act

        try? sut.askForCurrentLocation()
        mockLM.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: locations)

        // assert

        XCTAssertFalse(sut.currentLocationDealOnly)

        mockLM.verify_stopUpdatingLocation_CalledTwice()
#if os(iOS)
        mockLM.verify_requestLocation_CalledOnce()
#elseif os(macOS)
        mockLM.verify_startUpdatingLocation_CalledOnce()
#endif

        mockNC.verify_post_locationDealerNotification_withReceivedLocation(
            name: .locationDealerCurrentNotification, object: result)
    }

    func test_didUpdateLocations_currentLocationDealOnlyFalse_receivedLocations() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        let coord = CLLocationCoordinate2D(latitude: 87.90, longitude: 34.83)
        let firstLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

        let locations = [firstLocation, CLLocation(latitude: 34.78, longitude: 34.83)]
        let result: Result<[CLLocation], LocationDealerError> = .success(locations)

        // act

        sut.askToStartUpdatingLocation()
        mockLM.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: locations)

        // assert

        XCTAssertFalse(sut.currentLocationDealOnly)

        mockLM.verify_stopUpdatingLocation_CalledOnce()
        mockLM.verify_startUpdatingLocation_CalledOnce()

        mockNC.verify_post_locationDealerNotification_withReceivedLocations(
            name: .locationDealerUpdatesNotification, object: result)
    }

    func test_didUpdateLocations_currentLocationDealOnlyFalse_receivedEmptyLocationData() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        let error = LocationDealerError.receivedEmptyLocationData
        let result: Result<[CLLocation], LocationDealerError> = .failure(error)
        let locations = [CLLocation]()

        // act

        sut.askToStartUpdatingLocation()
        mockLM.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: locations)

        // assert

        XCTAssertFalse(sut.currentLocationDealOnly)

        mockLM.verify_stopUpdatingLocation_CalledOnce()
        mockLM.verify_startUpdatingLocation_CalledOnce()

        mockNC.verify_post_locationDealerUpdatesNotification_withError(
            name: .locationDealerUpdatesNotification, object: result)
    }
}
