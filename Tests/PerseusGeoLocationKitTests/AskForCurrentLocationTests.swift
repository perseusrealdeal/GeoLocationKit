//
//  AskForCurrentLocationTests.swift
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
@testable import PerseusGeoLocationKit

extension PerseusLocationDealerTests {

    func test_askForCurrentLocation_called() {

        // arrange

        var permit: LocationDealerPermit?

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        // act

        sut.askForCurrentLocation { locationPermit in permit = locationPermit }

        // assert

        XCTAssertNil(permit)

        mockLM.verify_stopUpdatingLocation_CalledOnce()

        XCTAssertTrue(sut.currentLocationDealOnly)
        XCTAssertEqual(sut.desiredAccuracy, APPROPRIATE_ACCURACY.rawValue)

        mockLM.verify_startUpdatingLocation_CalledOnce()
    }

    func test_askForCurrentLocation_actionIfNotAllowed_called() {

        // arrange

        var permit: LocationDealerPermit?

        MockLocationManager.status = .denied
        MockLocationManager.isLocationServiceEnabled = true

        // act

        sut.askForCurrentLocation { locationPermit in permit = locationPermit }

        // assert

        XCTAssertNotNil(permit)
        XCTAssertEqual(permit, .deniedForTheApp)
    }

    func test_askForCurrentLocation_with_specific_accuracy() {

        // arrange

        var permit: LocationDealerPermit?

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = true

        // act

        sut.askForCurrentLocation(accuracy: LocationAccuracy.kilometer) { locationPermit in
            permit = locationPermit
        }

        // assert

        XCTAssertNil(permit)
        XCTAssertEqual(sut.desiredAccuracy, LocationAccuracy.kilometer.rawValue)
    }
}
