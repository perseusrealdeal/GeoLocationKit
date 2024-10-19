//
//  AskForCurrentLocationTests.swift
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

extension PerseusLocationDealerTests {

    func test_askForCurrentLocation_should_throw_exception_with_actual_permit() {

        // arrange

        MockLocationManager.status = .denied
        MockLocationManager.isLocationServiceEnabled = true

        let exeption = LocationDealerError.needsPermission(.deniedForTheApp)

        // act, assert

        // simulate
        XCTAssertThrowsError(try sut.askForCurrentLocation()) { (error) in
            // catch exeption
            XCTAssertEqual(error as? LocationDealerError, exeption)
        }
    }

    func test_askForCurrentLocation_should_request_location() {

        // arrange

        #if os(iOS)
        MockLocationManager.status = .authorizedAlways
        #elseif os(macOS)
        MockLocationManager.status = .authorized
        #endif
        MockLocationManager.isLocationServiceEnabled = true

        // act

        try? sut.askForCurrentLocation()

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

    func test_askForCurrentLocation_should_set_the_accuracy() {

        // arrange

        #if os(iOS)
        MockLocationManager.status = .authorizedAlways
        #elseif os(macOS)
        MockLocationManager.status = .authorized
        #endif
        MockLocationManager.isLocationServiceEnabled = true

        // act

        try? sut.askForCurrentLocation(with: LocationAccuracy.best)

        // assert

        XCTAssertEqual(sut.locationManager.desiredAccuracy, LocationAccuracy.best.rawValue)
    }
}
