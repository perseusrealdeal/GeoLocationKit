//
//  AskForAuthorizationTests.swift
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

    func test_askForAuthorization_invokes_actionIfdetermined() {

        // arrange

        MockLocationManager.status = .denied
        MockLocationManager.isLocationServiceEnabled = true

        var actionIfdeterminedInvoked = false
        var permitReturned: LocationDealerPermit?

        // act

        sut.askForAuthorization(.always) { permit in
            actionIfdeterminedInvoked = true
            permitReturned = permit
        }

        // assert

        XCTAssertTrue(actionIfdeterminedInvoked)
        XCTAssertTrue(permitReturned == .deniedForTheApp)
    }
#if os(iOS)
    func test_askForAuthorization_invokes_requestWhenInUseAuthorization() {

        // arrange

        MockLocationManager.status = .notDetermined
        MockLocationManager.isLocationServiceEnabled = true

        // act

        sut.askForAuthorization(.whenInUse)

        // assert

        mockLM.verify_requestWhenInUseAuthorization_CalledOnce()

        XCTAssertTrue(sut.order == .none)
    }

    func test_askForAuthorization_invokes_requestAlwaysAuthorization() {

        // arrange

        MockLocationManager.status = .notDetermined
        MockLocationManager.isLocationServiceEnabled = true

        // act

        sut.askForAuthorization(.always)

        // assert

        mockLM.verify_requestAlwaysAuthorization_CalledOnce()

        XCTAssertTrue(sut.order == .none)
    }
#elseif os(macOS)
    func test_askForAuthorization() {

        // arrange

        MockLocationManager.status = .notDetermined
        MockLocationManager.isLocationServiceEnabled = true

        // act

        sut.askForAuthorization()

        // assert

        mockLM.verify_startUpdatingLocation_CalledOnce()

        XCTAssertTrue(sut.order == .authorization)
    }
#endif
}
