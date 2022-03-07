//
//  ServiceKey.swift
//  Core
//
//  Created by Clément Nonn on 09/06/2021.
//

import Foundation

public enum ServiceKey: String, CaseIterable {
    case features
    case mocks
    case environment
    case card
    case operations
    case restrictions
    case spendingLimits
    case contactInfo
    case merchantBlocking
    case countries
    case keycloakAuth
    case openId
    case customers
    case velocityLimits

    // There is some services that can't be mocked
    public static var unmockable: Set<ServiceKey> {
        [
            .features,
            .mocks,
            .environment
        ]
    }

    public static var mockable: Set<ServiceKey> {
        Set(Self.allCases.filter { !Self.unmockable.contains($0) })
    }
}

extension ServiceKey: CodingKey {
    public var stringValue: String { self.rawValue }
}
