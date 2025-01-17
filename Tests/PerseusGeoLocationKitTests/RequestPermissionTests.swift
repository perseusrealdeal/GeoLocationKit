//
//  RequestPermissionTests.swift
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

    func test_requestPermission_invokes_actionIfdetermined() {

        // arrange

        MockLocationManager.status = .denied
        MockLocationManager.isLocationServiceEnabled = true

        var actionIfdeterminedInvoked = false
        var permitReturned: LocationPermit?

        // act

        sut.requestPermission(.always) { permit in
            actionIfdeterminedInvoked = true
            permitReturned = permit
        }

        // assert

        XCTAssertTrue(actionIfdeterminedInvoked)
        XCTAssertTrue(permitReturned == .deniedForTheApp)
    }

    #if os(iOS)

    func test_requestPermission_invokes_requestWhenInUseAuthorization() {

        // arrange

        MockLocationManager.status = .notDetermined
        MockLocationManager.isLocationServiceEnabled = true

        // act

        sut.requestPermission(.whenInUse)

        // assert

        mockLM.verify_requestWhenInUseAuthorization_CalledOnce()

        XCTAssertTrue(sut.order == .none)
    }

    func test_requestPermission_invokes_requestAlwaysAuthorization() {

        // arrange

        MockLocationManager.status = .notDetermined
        MockLocationManager.isLocationServiceEnabled = true

        // act, assert

        sut.requestPermission(.always)

        // assert

        mockLM.verify_requestAlwaysAuthorization_CalledOnce()

        XCTAssertTrue(sut.order == .none)
    }

    #elseif os(macOS)

    func test_requestPermission_called_startUpdatingLocation() {

        // arrange

        MockLocationManager.status = .notDetermined
        MockLocationManager.isLocationServiceEnabled = true

        // act, assert

        sut.requestPermission()
        XCTAssertTrue(sut.order == .permission)

        // assert

        mockLM.verify_startUpdatingLocation_CalledOnce()

        XCTAssertTrue(sut.order == .permission)
    }

    func test_requestPermission_should_post_no_error_notification() {

        // arrange

        MockLocationManager.status = .notDetermined
        MockLocationManager.isLocationServiceEnabled = true

        let error = LocationError.failedRequest("")

        // act, assert

        sut.requestPermission()

        XCTAssertTrue(sut.order == .permission)
        XCTAssertTrue(sut.locationPermit == .notDetermined)
        mockLM.verify_startUpdatingLocation_CalledOnce()

        // act, assert

        mockLM.delegate?.locationManager?(CLLocationManager(), didFailWithError: error)

        mockLM.verify_stopUpdatingLocation_CalledOnce()
        mockNC.verify_no_post_locationDealerNotification_withError()
        XCTAssertTrue(sut.order == .permission)
    }

    #endif
}
