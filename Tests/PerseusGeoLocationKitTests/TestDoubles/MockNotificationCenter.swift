//
//  MockNotificationCenter.swift
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
// swiftlint:disable file_length empty_enum_arguments
//

import CoreLocation

import XCTest
@testable import PerseusGeoLocationKit

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
        XCTAssertEqual(postArgsObject.first as? CLAuthorizationStatus,
                       anObject as? CLAuthorizationStatus, "object", file: file, line: line)
    }

    func verify_no_post_locationDealerNotification_withError(
        file: StaticString = #file,
        line: UInt = #line) {
        guard postCalledNone(file: file, line: line) else { return }
    }

    func verify_post_locationDealerNotification_withError(
        name aName: NSNotification.Name?,
        object anObject: Any?,
        file: StaticString = #file,
        line: UInt = #line) {
        guard postCalledOnce(file: file, line: line) else { return }

        XCTAssertEqual(postArgsName.first, aName, "name", file: file, line: line)
        XCTAssertNotNil(anObject, file: file, line: line)

        let result = postArgsObject.first as? LocationError
        let theObject = anObject as? LocationError

        XCTAssertTrue(result == theObject, "object", file: file, line: line)
    }

    func verify_post_locationDealerUpdatesNotification_withError(
        name aName: NSNotification.Name?,
        object anObject: Any?,
        file: StaticString = #file,
        line: UInt = #line) {
        guard postCalledOnce(file: file, line: line) else { return }

        XCTAssertEqual(postArgsName.first, aName, "name", file: file, line: line)
        XCTAssertNotNil(anObject, file: file, line: line)

        let result = postArgsObject.first as? Result<[PerseusLocation], LocationError>
        let theObject = anObject as? Result<[PerseusLocation], LocationError>

        var errorArgs: LocationError?
        if let result = result {
            switch result {
            case .success(_):
                break
            case .failure(let error):
                errorArgs = error
            }
        }

        var object: LocationError?
        if let theObject = theObject {
            switch theObject {
            case .success(_):
                break
            case .failure(let error):
                object = error
            }
        }

        XCTAssertNotNil(result, "result", file: file, line: line)
        XCTAssertNotNil(theObject, "the object", file: file, line: line)

        XCTAssertTrue(errorArgs == object, "object", file: file, line: line)
    }

    func verify_post_locationDealerNotification_withReceivedLocation(
        name aName: NSNotification.Name?,
        object anObject: Any?,
        file: StaticString = #file,
        line: UInt = #line) {
        guard postCalledOnce(file: file, line: line) else { return }

        XCTAssertEqual(postArgsName.first, aName, "name", file: file, line: line)
        XCTAssertNotNil(anObject, file: file, line: line)

        let result = postArgsObject.first as? Result<PerseusLocation, LocationError>
        let theObject = anObject as? Result<PerseusLocation, LocationError>

        var locationArgs: PerseusLocation?
        if let result = result {
            switch result {
            case .success(let location):
                locationArgs = location
                log.message("\(location)")
            case .failure(_):
                break
            }
        }

        var object: PerseusLocation?
        if let theObject = theObject {
            switch theObject {
            case .success(let location):
                object = location
                log.message("\(location)")
            case .failure(_):
                break
            }
        }

        XCTAssertNotNil(result, "result", file: file, line: line)
        XCTAssertNotNil(theObject, "the object", file: file, line: line)

        XCTAssertEqual(locationArgs, object, "object", file: file, line: line)
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
            postArgsObject.first as? Result<[PerseusLocation], LocationError>
        let theObject = anObject as? Result<[PerseusLocation], LocationError>

        var locationArgs: [PerseusLocation]?
        if let result = result {
            switch result {
            case .success(let locations):
                locationArgs = locations
            case .failure(_):
                break
            }
        }

        var object: [PerseusLocation]?
        if let theObject = theObject {
            switch theObject {
            case .success(let locations):
                object = locations
            case .failure( _):
                break
            }
        }

        XCTAssertNotNil(result, "result", file: file, line: line)
        XCTAssertNotNil(theObject, "the object", file: file, line: line)

        XCTAssertEqual(locationArgs, object, "object", file: file, line: line)
    }

    private func postCalledNone(file: StaticString = #file,
                                line: UInt = #line) -> Bool {
        return verifyMethodCalledNone(
            methodName: "post(name aName:, object anObject:)",
            callCount: postCallCount,
            describeArguments: "args: \(postArgsName)",
            file: file,
            line: line)
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

private func verifyMethodCalledNone(methodName: String,
                                    callCount: Int,
                                    describeArguments: @autoclosure () -> String,
                                    file: StaticString = #file,
                                    line: UInt = #line) -> Bool {

    if callCount > 0 {
        XCTFail("Wanted not invoked but was called \(callCount) times. " +
            "\(methodName) with \(describeArguments())", file: file, line: line)
        return false
    }

    return true
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

// swiftlint:enable file_length empty_enum_arguments
