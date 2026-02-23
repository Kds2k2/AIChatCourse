//
//  PurchasedEntitlement+RevenueCat.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 22.02.2026.
//

import SwiftUI
import RevenueCat

extension PurchasedEntitlement {
    init(entitlement: EntitlementInfo) {
        self.init(
            id: entitlement.identifier,
            productId: entitlement.productIdentifier,
            expirationDate: entitlement.expirationDate,
            isActive: entitlement.isActive,
            originalPurchaseDate: entitlement.originalPurchaseDate,
            latestPurchaseDate: entitlement.latestPurchaseDate,
            ownershipType: EntitlementOwnershipOption(type: entitlement.ownershipType),
            isSandbox: entitlement.isSandbox,
            isVerified: entitlement.verification.isVerified
        )
    }
}

extension Dictionary where Key == String, Value == EntitlementInfo {
    var asPurchasedEntitlement: [PurchasedEntitlement] {
        let entitlements = self.compactMap { _, entitlement in
            PurchasedEntitlement(entitlement: entitlement)
        }
        return entitlements
    }
}
