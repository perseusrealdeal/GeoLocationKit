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
        sut.resetDefaults()
    }

    // func test_zero() { XCTFail("Tests not yet implemented in \(type(of: self)).") }
    // func test_the_first_success() { XCTAssertTrue(true, "It's done!") }

    func test_PerseusLocationDealerInit() {

        // arrange, act, assert

        XCTAssertNotNil(sut.locationManager)
        XCTAssertNotNil(sut.notificationCenter)
        XCTAssertFalse(sut.currentLocationDealOnly)
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

// MARK: - request authorization tests (only iOS)

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

// MARK: - locationPermit tests

extension PerseusLocationDealerTests {

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

// MARK: - askForCurrentLocation tests

extension PerseusLocationDealerTests {


    func test_askForCurrentLocation_called() {

        // arrange

        var permit: LocationDealerPermit? = nil

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

        var permit: LocationDealerPermit? = nil

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

        var permit: LocationDealerPermit? = nil

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
