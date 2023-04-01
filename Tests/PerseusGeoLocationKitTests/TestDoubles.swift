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
    var desiredAccuracy: CLLocationAccuracy = APPROPRIATE_ACCURACY.rawValue

    var startUpdatingLocationCallCount: Int = 0
    var stopUpdatingLocationCallCount: Int = 0

    func startUpdatingLocation() {
        #if DEBUG
        //if printMessagesInConsole { print(">> [\(type(of: self))]." + #function) }
        #endif

        startUpdatingLocationCallCount += 1
    }

    func stopUpdatingLocation() {
        #if DEBUG
        if printMessagesInConsole { print(">> [\(type(of: self))]." + #function) }
        #endif

        stopUpdatingLocationCallCount += 1
    }

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

    func verify_stopUpdatingLocation_CalledTwice(file: StaticString = #file,
                                                 line: UInt = #line) {
        if stopUpdatingLocationCallCount == 0 {
            XCTFail("Wanted but not invoked: stopUpdatingLocation()", file: file, line: line)
        }

        if stopUpdatingLocationCallCount == 1 {
            XCTFail("Wanted 2 times but was called \(stopUpdatingLocationCallCount) times. " +
                "stopUpdatingLocation()", file: file, line: line)
        }

        if stopUpdatingLocationCallCount > 2 {
            XCTFail("Wanted 2 times but was called \(stopUpdatingLocationCallCount) times. " +
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

class MockNotificationCenter: NotificationCenterProtocol {

    var postCallCount = 0

    var postArgsName: [NSNotification.Name?] = []
    var postArgsObject: [Any?] = []

    func post(name aName: NSNotification.Name, object anObject: Any?) {
        postCallCount += 1
        postArgsName.append(aName)
        postArgsObject.append(anObject)
    }

    func verify_post_didChangeAuthorization(
        name aName: NSNotification.Name?,
        object anObject: Any?,
        file: StaticString = #file,
        line: UInt = #line) {
        guard postCalledOnce(file: file, line: line) else { return }

        XCTAssertEqual(postArgsName.first, aName, "name", file: file, line: line)
        XCTAssertNotNil(anObject, file: file, line: line)
        XCTAssertEqual(postArgsObject.first as! CLAuthorizationStatus,
                       anObject as! CLAuthorizationStatus, "object", file: file, line: line)


    }

    func verify_post_locationDealerNotification_withError(
        name aName: NSNotification.Name?,
        object anObject: Any?,
        file: StaticString = #file,
        line: UInt = #line) {
        guard postCalledOnce(file: file, line: line) else { return }

        XCTAssertEqual(postArgsName.first, aName, "name", file: file, line: line)
        XCTAssertNotNil(anObject, file: file, line: line)

        let result =
            postArgsObject.first as? Result<[CLLocation], LocationDealerError>
        let theObject = anObject as? Result<[CLLocation], LocationDealerError>

        var errorArgs: LocationDealerError?
        if let result = result {
            switch result {
            case .success(_):
                break
            case .failure(let error):
                errorArgs = error
            }
        }

        var object: LocationDealerError?
        if let theObject = theObject {
            switch theObject {
            case .success(_):
                break
            case .failure(let error):
                object = error
            }
        }

        XCTAssertTrue(errorArgs == object, "object", file: file, line: line)
    }

    func verify_post_locationDealerNotification_withReceivedLocations(
        name aName: NSNotification.Name?,
        object anObject: Any?,
        file: StaticString = #file,
        line: UInt = #line) {
        guard postCalledOnce(file: file, line: line) else { return }

        XCTAssertEqual(postArgsName.first, aName, "name", file: file, line: line)
        XCTAssertNotNil(anObject, file: file, line: line)

        let result =
            postArgsObject.first as? Result<[CLLocation], LocationDealerError>
        let theObject = anObject as? Result<[CLLocation], LocationDealerError>

        var locationArgs: [CLLocation]?
        if let result = result {
            switch result {
            case .success(let locations):
                locationArgs = locations
            case .failure(_):
                break
            }
        }

        var object: [CLLocation]?
        if let theObject = theObject {
            switch theObject {
            case .success(let locations):
                object = locations
            case .failure(_):
                break
            }
        }

        // XCTAssertTrue(locationArgs == object, "object", file: file, line: line)
        XCTAssertEqual(locationArgs, object, "object", file: file, line: line)
    }

    private func postCalledOnce(file: StaticString = #file,
                                line: UInt = #line) -> Bool {
        return verifyMethodCalledOnce(
            methodName: "post(name aName:, object anObject:)",
            callCount: postCallCount,
            describeArguments: "args: \(postArgsName)",
            file: file,
            line: line)
    }
}

private func verifyMethodCalledOnce(methodName: String,
                                    callCount: Int,
                                    describeArguments: @autoclosure () -> String,
                                    file: StaticString = #file,
                                    line: UInt = #line) -> Bool {
    if callCount == 0 {
        XCTFail("Wanted but not invoked: \(methodName)", file: file, line: line)
        return false
    }

    if callCount > 1 {
        XCTFail("Wanted 1 time but was called \(callCount) times. " +
            "\(methodName) with \(describeArguments())", file: file, line: line)
        return false
    }

    return true
}

/*
extension CLLocationCoordinate2D: Equatable { }

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
*/
