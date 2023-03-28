//
//  GeoLocationServiceTests.swift
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

final class PerseusLocationDealerTests: XCTestCase {

    private var sut = PerseusLocationDealer.shared

    private var mockLM: MockLocationManager!
    private var mockNC: MockNotificationCenter!

    override func setUp() {
        super.setUp()

        mockLM = MockLocationManager()
        mockNC = MockNotificationCenter()

        mockLM.delegate = sut
        sut.locationManager = mockLM
        sut.notificationCenter = mockNC
    }

    override func tearDown() {
        mockLM = nil
        mockNC = nil

        sut.locationManager = nil
        sut.notificationCenter = nil
    }

    // func test_zero() { XCTFail("Tests not yet implemented in \(type(of: self)).") }
    // func test_the_first_success() { XCTAssertTrue(true, "It's done!") }

    func test_PerseusLocationDealerInit() {

        // arrange, act, assert

        XCTAssertNotNil(sut.locationManager)
        XCTAssertNotNil(sut.notificationCenter)
        XCTAssertTrue(sut.currentLocationDealOnly)
        XCTAssertEqual(sut.locationManager.desiredAccuracy, APPROPRIATE_ACCURACY.rawValue)
    }

    func test_authorizationStatus() {

        // arrange

        MockLocationManager.status = .restricted

        // act

        let result = sut.authorizationStatus

        // assert

        XCTAssertEqual(result, .restricted)
    }

    func test_locationServicesEnabled() {

        // arrange

        MockLocationManager.isLocationServiceEnabled = false

        // act

        let result = sut.locationServicesEnabled

        // assert

        XCTAssertFalse(result)
    }

    func test_desiredAccuracy() {

        // arrange, act

        mockLM.desiredAccuracy = LocationAccuracy.kilometer.rawValue

        // arrange

        XCTAssertEqual(sut.desiredAccuracy, LocationAccuracy.kilometer.rawValue)
    }
}

#if os(iOS)
extension PerseusLocationDealerTests {

    func test_requestWhenInUseAuthorization() {

        // arrange, act

        sut.askForAuthorization(.whenInUse)

        // assert

        mockLM.verify_requestWhenInUseAuthorization_CalledOnce()
    }

    func test_requestAlwaysAuthorization() {

        // arrange, act

        sut.askForAuthorization(.always)

        // assert

        mockLM.verify_requestAlwaysAuthorization_CalledOnce()
    }
}
#endif
