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

    private let two = 100.0
    private let four = 10000.0

    public var description: String {

        let locationTwo = "[\(latitudeTwo), \(longitudeTwo)]"
        let locationFour = "latitude = \(latitudeFour), longitude = \(longitudeFour)"

        return locationTwo + ": " + locationFour
    }

    // MARK: - Location Data, As Is

    let location: CLLocation

    var latitude: Double { return location.coordinate.latitude }
    var longitude: Double { return location.coordinate.longitude }

    // MARK: - Location Data, Specifics

    // Cutting off to hundredths (2 decimal places).
    var latitudeTwo: Double {
        return (latitude * two).rounded(latitude > 0 ? .down : .up) / two
    }

    // Cutting off to hundredths (2 decimal places).
    var longitudeTwo: Double {
        return (longitude * two).rounded(longitude > 0 ? .down : .up) / two
    }

    // Cutting off to hundredths (4 decimal places).
    var latitudeFour: Double {
        return (latitude * four).rounded(latitude > 0 ? .down : .up) / four
    }

    // Cutting off to hundredths (4 decimal places).
    var longitudeFour: Double {
        return (longitude * four).rounded(longitude > 0 ? .down : .up) / four
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
