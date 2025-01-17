//
//  RequestCurrentLocationTests.swift
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
@testable import PerseusGeoLocationKit

extension LocationAgentTests {

    func test_requestCurrentLocation_should_throw_exception_with_actual_permit() {

        // arrange

        MockLocationManager.status = .denied
        MockLocationManager.isLocationServiceEnabled = true

        let exeption = LocationError.needsPermission(.deniedForTheApp)

        // act, assert

        // simulate
        XCTAssertThrowsError(try sut.requestCurrentLocation()) { (error) in
            // catch exeption
            XCTAssertEqual(error as? LocationError, exeption)
        }
    }

    func test_requestCurrentLocation_should_request_location() {

        // arrange

        #if os(iOS)
        MockLocationManager.status = .authorizedAlways
        #elseif os(macOS)
        MockLocationManager.status = .authorized
        #endif
        MockLocationManager.isLocationServiceEnabled = true

        // act

        try? sut.requestCurrentLocation()

        // assert

        mockLM.verify_stopUpdatingLocation_CalledOnce()

        XCTAssertTrue(sut.order == .currentLocation)
        XCTAssertEqual(sut.locationManager.desiredAccuracy, APPROPRIATE_ACCURACY.rawValue)

        #if os(iOS)
        mockLM.verify_requestLocation_CalledOnce()
        #elseif os(macOS)
        mockLM.verify_startUpdatingLocation_CalledOnce()
        #endif
    }

    func test_requestCurrentLocation_should_set_the_accuracy() {

        // arrange

        #if os(iOS)
        MockLocationManager.status = .authorizedAlways
        #elseif os(macOS)
        MockLocationManager.status = .authorized
        #endif
        MockLocationManager.isLocationServiceEnabled = true

        // act

        try? sut.requestCurrentLocation(with: LocationAccuracy.best)

        // assert

        XCTAssertEqual(sut.locationManager.desiredAccuracy, LocationAccuracy.best.rawValue)
    }
}
