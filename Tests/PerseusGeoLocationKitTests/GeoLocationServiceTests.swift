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

final class GeoLocationServiceTests: XCTestCase {

    // func test_zero() { XCTFail("Tests not yet implemented in \(type(of: self)).") }

    func test_the_first_success() { XCTAssertTrue(true, "It's done!") }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests.
        XCTAssertEqual(GeoLocationService().text, "Hello, World!")
    }
}
