//
//  LocationAccuracy.swift
//  PerseusGeoLocationKit
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 - 7533 Mikhail A. Zhigulin of Novosibirsk
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import Foundation
import CoreLocation

public struct LocationAccuracy: RawRepresentable, Equatable {

    // MARK: - RawRepresentable

    public var rawValue: CLLocationAccuracy

    // MARK: - Values

    // The highest possible accuracy that uses additional sensor data.
    public static let bestForNavigation = LocationAccuracy(
        rawValue: kCLLocationAccuracyBestForNavigation)

    // The best level of accuracy available.
    public static let best = LocationAccuracy(
        rawValue: kCLLocationAccuracyBest)

    // Accurate to within ten meters of the desired target.
    public static let nearestTenMeters = LocationAccuracy(
        rawValue: kCLLocationAccuracyNearestTenMeters)

    // Accurate to within one hundred meters.
    public static let hundredMeters = LocationAccuracy(
        rawValue: kCLLocationAccuracyHundredMeters)

    // Accurate to the nearest kilometer.
    public static let kilometer = LocationAccuracy(
        rawValue: kCLLocationAccuracyKilometer)

    // Accurate to the nearest three kilometers.
    public static let threeKilometers = LocationAccuracy(
        rawValue: kCLLocationAccuracyThreeKilometers)

    // MARK: - Initializer

    public init(rawValue: CLLocationAccuracy) {
        self.rawValue = rawValue
    }
}
