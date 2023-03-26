//
//  TestDoubles.swift
//  PerseusGeoLocationKitTests
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 Mikhail Zhigulin of Novosibirsk.
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import CoreLocation

import XCTest
@testable import PerseusGeoLocationKit

class MockLocationManager: LocationManagerProtocol {

    static var status: CLAuthorizationStatus = .notDetermined
    static var isLocationServiceEnabled: Bool = true

    static func authorizationStatus() -> CLAuthorizationStatus { return status }
    static func locationServicesEnabled() -> Bool { return isLocationServiceEnabled }

    weak var delegate: CLLocationManagerDelegate?
    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyThreeKilometers

    var startUpdatingLocationCallCount: Int = 0
    var stopUpdatingLocationCallCount: Int = 0

    func startUpdatingLocation() { startUpdatingLocationCallCount += 1 }
    func stopUpdatingLocation() { stopUpdatingLocationCallCount += 1 }

    func verify_startUpdatingLocation_CalledOnce(file: StaticString = #file,
                                                 line: UInt = #line) {
        if startUpdatingLocationCallCount == 0 {
            XCTFail("Wanted but not invoked: startUpdatingLocation()",
                    file: file, line: line)
        }

        if startUpdatingLocationCallCount > 1 {
            XCTFail("Wanted 1 time but was called \(startUpdatingLocationCallCount) times. " +
                "startUpdatingLocation()", file: file, line: line)
        }
    }

    func verify_stopUpdatingLocation_CalledOnce(file: StaticString = #file,
                                                line: UInt = #line) {
        if stopUpdatingLocationCallCount == 0 {
            XCTFail("Wanted but not invoked: stopUpdatingLocation()", file: file, line: line)
        }

        if stopUpdatingLocationCallCount > 1 {
            XCTFail("Wanted 1 time but was called \(stopUpdatingLocationCallCount) times. " +
                "stopUpdatingLocation()", file: file, line: line)
        }
    }

    #if os(iOS)

    var requestWhenInUseAuthorizationCallCount: Int = 0
    var requestAlwaysAuthorizationCallCount: Int = 0

    func requestWhenInUseAuthorization() { requestWhenInUseAuthorizationCallCount += 1 }
    func requestAlwaysAuthorization() { requestAlwaysAuthorizationCallCount += 1 }

    func verify_requestWhenInUseAuthorization_CalledOnce(file: StaticString = #file,
                                                         line: UInt = #line) {
        if requestWhenInUseAuthorizationCallCount == 0 {
            XCTFail("Wanted but not invoked: requestWhenInUseAuthorization()",
                    file: file, line: line)
        }

        if requestWhenInUseAuthorizationCallCount > 1 {
            XCTFail("Wanted 1 time but was called " +
                "\(requestWhenInUseAuthorizationCallCount) times. " +
                "requestWhenInUseAuthorization()", file: file, line: line)
        }
    }

    func verify_requestAlwaysAuthorization_CalledOnce(file: StaticString = #file,
                                                      line: UInt = #line) {
        if requestAlwaysAuthorizationCallCount == 0 {
            XCTFail("Wanted but not invoked: requestAlwaysAuthorization()",
                    file: file, line: line)
        }

        if requestAlwaysAuthorizationCallCount > 1 {
            XCTFail("Wanted 1 time but was called " +
                "\(requestAlwaysAuthorizationCallCount) times. " +
                "requestAlwaysAuthorization()", file: file, line: line)
        }
    }

    #endif
}
