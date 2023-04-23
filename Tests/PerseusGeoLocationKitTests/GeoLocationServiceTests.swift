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
import CoreLocation
@testable import PerseusGeoLocationKit

#if os(iOS)
let authorized: CLAuthorizationStatus = .authorizedAlways
#elseif os(macOS)
let authorized: CLAuthorizationStatus = .authorized
#endif

final class PerseusLocationDealerTests: XCTestCase {

    internal var sut = PerseusLocationDealer.shared

    internal var mockLM: MockLocationManager!
    internal var mockNC: MockNotificationCenter!

    override func setUp() {
        log.message("[\(type(of: self))].\(#function)")

        super.setUp()

        mockLM = MockLocationManager()
        mockNC = MockNotificationCenter()

        mockLM.delegate = sut
        sut.locationManager = mockLM
        sut.notificationCenter = mockNC
    }

    override func tearDown() {
        log.message("[\(type(of: self))].\(#function)")

        mockLM = nil
        mockNC = nil

        sut.locationManager = nil
        sut.notificationCenter = nil
        sut.resetDefaults()

        super.tearDown()
    }

    // func test_zero() { XCTFail("Tests not yet implemented in \(type(of: self)).") }
    // func test_the_first_success() { XCTAssertTrue(true, "It's done!") }

    func test_PerseusLocationDealerInit() {

        // arrange, act, assert

        XCTAssertNotNil(sut.locationManager)
        XCTAssertNotNil(sut.notificationCenter)
        XCTAssertTrue(sut.order == .none)
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

    func test_startUpdatingLocation() {

        // arrange, act

        sut.askToStartUpdatingLocation(accuracy: .best)

        // assert

        mockLM.verify_startUpdatingLocation_CalledOnce()

        XCTAssertTrue(sut.order == .locationUpdates)
        XCTAssertEqual(sut.desiredAccuracy, LocationAccuracy.best.rawValue)
    }

    func test_stopUpdatingLocation() {

        // arrange, act

        sut.askToStopUpdatingLocation()

        // assert

        mockLM.verify_stopUpdatingLocation_CalledOnce()
        XCTAssertTrue(sut.order == .none)
    }
}
