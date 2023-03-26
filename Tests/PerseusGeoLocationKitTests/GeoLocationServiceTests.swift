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

    private var sut: PerseusLocationDealer!
    private var mock: MockLocationManager!

    override func setUp() {
        super.setUp()

        sut = PerseusLocationDealer.shared
        mock = MockLocationManager()

        mock.delegate = sut
        sut.locationManager = mock
    }

    // func test_zero() { XCTFail("Tests not yet implemented in \(type(of: self)).") }

    func test_the_first_success() { XCTAssertTrue(true, "It's done!") }
}
