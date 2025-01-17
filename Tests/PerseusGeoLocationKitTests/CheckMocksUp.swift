//
//  CheckMocksUp.swift
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

    func test_PerseusLocationDealerInit() {

        // arrange, act, assert

        // TASK: Those statements of the initializer should be covered.
        // In fact the following assertions test mocks, not the business matter statements.

         XCTAssertNotNil(sut.locationManager)
         XCTAssertNotNil(sut.notificationCenter)

         XCTAssertTrue(sut.order == .none)

         XCTAssertEqual(sut.locationManager.desiredAccuracy, APPROPRIATE_ACCURACY.rawValue)
         XCTAssertTrue(sut === sut.locationManager.delegate)
    }

    func test_authorizationStatus() {

        // arrange

        MockLocationManager.status = .restricted

        // act

        let result = type(of: sut.locationManager).authorizationStatus()

        // assert

        XCTAssertEqual(result, .restricted)
    }

    func test_locationServicesEnabled() {

        // arrange

        MockLocationManager.isLocationServiceEnabled = false

        // act

        let result = type(of: sut.locationManager).locationServicesEnabled()

        // assert

        XCTAssertFalse(result)
    }

    func test_desiredAccuracy() {

        // arrange, act

        mockLM.desiredAccuracy = LocationAccuracy.best.rawValue

        // arrange

        XCTAssertEqual(sut.locationManager.desiredAccuracy, LocationAccuracy.best.rawValue)
    }
}
