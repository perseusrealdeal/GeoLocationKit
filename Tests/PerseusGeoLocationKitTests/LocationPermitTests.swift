//
//  LocationPermitTests.swift
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

    func test_locationPermit_should_return_notDetermined() {

        // arrange

        MockLocationManager.status = .notDetermined

        // act

        let permit = sut.locationPermit

        // assert

        XCTAssertEqual(permit, .notDetermined)
    }

    func test_locationPermit_should_return_deniedForTheApp() {

        // arrange

        MockLocationManager.status = .denied
        MockLocationManager.isLocationServiceEnabled = true

        // act

        let permit = sut.locationPermit

        // assert

        XCTAssertEqual(permit, .deniedForTheApp)
    }

    func test_locationPermit_should_return_deniedForAllApps() {

        // arrange

        MockLocationManager.status = .denied
        MockLocationManager.isLocationServiceEnabled = false

        // act

        let permit = sut.locationPermit

        // assert

        XCTAssertEqual(permit, .deniedForAllApps)
    }

    func test_locationPermit_should_return_restricted() {

        // arrange

        MockLocationManager.status = .restricted
        MockLocationManager.isLocationServiceEnabled = true

        // act

        let permit = sut.locationPermit

        // assert

        XCTAssertEqual(permit, .restricted)
    }

    func test_locationPermit_should_return_deniedForAllAndRestricted() {

        // arrange

        MockLocationManager.status = .restricted
        MockLocationManager.isLocationServiceEnabled = false

        // act

        let permit = sut.locationPermit

        // assert

        XCTAssertEqual(permit, .deniedForAllAndRestricted)
    }

    func test_locationPermit_should_return_allowed() {

        // arrange

        MockLocationManager.status = authorized
        MockLocationManager.isLocationServiceEnabled = false

        // act

        let permit = sut.locationPermit

        // assert

        XCTAssertEqual(permit, .allowed)
    }
}
