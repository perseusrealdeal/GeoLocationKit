//
//  LocationAgentTests.swift
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

#if os(iOS)
let authorized: CLAuthorizationStatus = .authorizedAlways
#elseif os(macOS)
let authorized: CLAuthorizationStatus = .authorized
#endif

final class LocationAgentTests: XCTestCase {

    internal let sut = LocationAgent.shared

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
        sut.locationManager.delegate = sut
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

    func test_startUpdatingLocation() {

        // arrange, act

        sut.startUpdatingLocation(accuracy: .best)

        // assert

        mockLM.verify_startUpdatingLocation_CalledOnce()

        XCTAssertTrue(sut.order == .locationUpdates)
        XCTAssertEqual(sut.locationManager.desiredAccuracy, LocationAccuracy.best.rawValue)
    }

    func test_stopUpdatingLocation() {

        // arrange, act

        sut.stopUpdatingLocation()

        // assert

        mockLM.verify_stopUpdatingLocation_CalledOnce()
        XCTAssertTrue(sut.order == .none)
    }
}
