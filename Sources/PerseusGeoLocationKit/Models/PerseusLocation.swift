//
//  PerseusLocation.swift
//  PerseusGeoLocationKit
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 Mikhail Zhigulin of Novosibirsk.
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation { public var perseus: PerseusLocation { return PerseusLocation(self) } }

public struct PerseusLocation: CustomStringConvertible, Equatable {

    // MARK: - Data Preview

    public var description: String {
        let lat = (latitude * 10000.0).rounded(latitude > 0 ? .down : .up) / 10000.0
        let lon = (longitude * 10000.0).rounded(longitude > 0 ? .down : .up) / 10000.0

        let location100 = "[\(latitudeHundredths), \(longitudeHundredths)]"
        let location10000 = "latitude = \(lat), longitude = \(lon)"

        return location100 + ": " + location10000
    }

    // MARK: - Location Data, As Is

    let location: CLLocation

    var latitude: Double { return location.coordinate.latitude }
    var longitude: Double { return location.coordinate.longitude }

    // MARK: - Location Data, Specifics

    // Cutting off to hundredths (2 decimal places).
    var latitudeHundredths: Double {
        return (latitude * 100.0).rounded(latitude > 0 ? .down : .up) / 100.0
    }

    // Cutting off to hundredths (2 decimal places).
    var longitudeHundredths: Double {
        return (longitude * 100.0).rounded(longitude > 0 ? .down : .up) / 100.0
    }

    // MARK: - Initializer

    public init(_ location: CLLocation) {
        self.location = location
    }

    // MARK: - Equatable

    public static func == (lhs: PerseusLocation, rhs: PerseusLocation) -> Bool {
        return lhs.location == rhs.location
    }
}
