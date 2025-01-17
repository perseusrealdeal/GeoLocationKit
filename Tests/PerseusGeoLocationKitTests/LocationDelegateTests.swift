//
//  LocationDelegateTests.swift
//  PerseusGeoLocationKitTests
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 - 7533 Mikhail A. Zhigulin of Novosibirsk
//  Copyright © 7533 PerseusRealDeal
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import XCTest
import CoreLocation
@testable import PerseusGeoLocationKit

extension LocationAgentTests {

    func test_didChangeAuthorization() {

        // arrange, act

        mockLM.delegate?.locationManager?(CLLocationManager(),
                                          didChangeAuthorization: .restricted)

        // assert

        mockNC.verify_post_didChangeAuthorization(
            name: .locationDealerStatusChangedNotification,
            object: CLAuthorizationStatus.restricted)
    }

    func test_didFailWithError_currentLocation() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        let error = LocationError.failedRequest("")
        let result: LocationError = .failedRequest(error.localizedDescription)

        // act, assert

        try? sut.requestCurrentLocation()
        XCTAssertTrue(sut.order == .currentLocation)

        mockLM.delegate?.locationManager?(CLLocationManager(), didFailWithError: error)
        XCTAssertTrue(sut.order == .none)

        mockLM.verify_stopUpdatingLocation_CalledTwice()
        #if os(iOS)
        mockLM.verify_requestLocation_CalledOnce()
        #elseif os(macOS)
        mockLM.verify_startUpdatingLocation_CalledOnce()
        #endif

        mockNC.verify_post_locationDealerNotification_withError(
            name: .locationDealerErrorNotification, object: result)
    }

    func test_didUpdateLocations_currentLocation_receivedEmptyLocationData() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        let error = LocationError.receivedEmptyLocationData
        let result: Result<CLLocation, LocationError> = .failure(error)
        let locations = [CLLocation]()

        // act, assert

        try? sut.requestCurrentLocation()
        XCTAssertTrue(sut.order == .currentLocation)

        mockLM.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: locations)
        XCTAssertTrue(sut.order == .none)

        // assert

        mockLM.verify_stopUpdatingLocation_CalledTwice()
        #if os(iOS)
        mockLM.verify_requestLocation_CalledOnce()
        #elseif os(macOS)
        mockLM.verify_startUpdatingLocation_CalledOnce()
        #endif

        mockNC.verify_post_locationDealerNotification_withError(
            name: .locationDealerCurrentNotification, object: result)
    }

    func test_didUpdateLocations_currentLocation_receivedCurrentLocation() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        let coord = CLLocationCoordinate2D(latitude: 87.90, longitude: 34.83)
        let firstLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

        let locations = [firstLocation, CLLocation(latitude: 34.78, longitude: 34.83)]
        let perseusLocation = firstLocation.perseus
        let result: Result<PerseusLocation, LocationError> = .success(perseusLocation)

        // act, assert

        try? sut.requestCurrentLocation()
        XCTAssertTrue(sut.order == .currentLocation)

        mockLM.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: locations)
        XCTAssertTrue(sut.order == .none)

        // assert

        mockLM.verify_stopUpdatingLocation_CalledTwice()
        #if os(iOS)
        mockLM.verify_requestLocation_CalledOnce()
        #elseif os(macOS)
        mockLM.verify_startUpdatingLocation_CalledOnce()
        #endif

        mockNC.verify_post_locationDealerNotification_withReceivedLocation(
            name: .locationDealerCurrentNotification, object: result)
    }

    func test_didUpdateLocations_UpdatingLocation_receivedLocations() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        let coord = CLLocationCoordinate2D(latitude: 87.90, longitude: 34.83)
        let firstLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

        let locations = [firstLocation, CLLocation(latitude: 34.78, longitude: 34.83)]
        let perseusLocations = locations.map { $0.perseus }
        let result: Result<[PerseusLocation], LocationError> = .success(perseusLocations)

        // act, assert

        sut.startUpdatingLocation()
        XCTAssertTrue(sut.order == .locationUpdates)

        mockLM.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: locations)
        XCTAssertTrue(sut.order == .locationUpdates)

        // assert

        mockLM.verify_startUpdatingLocation_CalledOnce()

        mockNC.verify_post_locationDealerNotification_withReceivedLocations(
            name: .locationDealerUpdatesNotification, object: result)
    }

    func test_didUpdateLocations_UpdatingLocation_receivedEmptyLocationData() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        let error = LocationError.receivedEmptyLocationData
        let result: Result<[PerseusLocation], LocationError> = .failure(error)
        let locations = [CLLocation]()

        // act, assert

        sut.startUpdatingLocation()
        XCTAssertTrue(sut.order == .locationUpdates)

        mockLM.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: locations)
        XCTAssertTrue(sut.order == .none)

        // assert

        mockLM.verify_stopUpdatingLocation_CalledOnce()
        mockLM.verify_startUpdatingLocation_CalledOnce()

        mockNC.verify_post_locationDealerUpdatesNotification_withError(
            name: .locationDealerUpdatesNotification, object: result)
    }
}
