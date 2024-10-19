//
//  LocationDealerError.swift
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

public enum LocationDealerError: Error, Equatable {

    case needsPermission(LocationDealerPermit)
    case receivedEmptyLocationData
    case failedRequest(String)
}
