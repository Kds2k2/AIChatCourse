//
//  EntitlementOwnershipOption.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 21.02.2026.
//

import SwiftUI

public enum EntitlementOwnershipOption: Codable, Sendable {
    case purchased, familyShared, unknown
}

import StoreKit

extension EntitlementOwnershipOption {
    init(type: Transition.OwnershipType) {
        switch type {
        case .purchased:
            self = .purchased
        case .familyShared:
            self = .familyShared
        default:
            self = .unknown
        }
    }
}
