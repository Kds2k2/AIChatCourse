//
//  RevenueCatPurchaseService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 23.02.2026.
//

import SwiftUI
import RevenueCat

actor RevenueCatPurchaseService: PurchaseService {
    
    init(apiKey: String, logLevel: LogLevel = .warn) {
        Purchases.configure(withAPIKey: apiKey)
        Purchases.logLevel = logLevel
        Purchases.shared.attribution.collectDeviceIdentifiers()
    }
    
    func listenForTransactions(onTransactionsUpdated: @escaping @Sendable ([PurchasedEntitlement]) async -> Void) async {
        for await customerInfo in Purchases.shared.customerInfoStream {
            let entitlements = await customerInfo.entitlements.all.asPurchasedEntitlement
            await onTransactionsUpdated(entitlements)
        }
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        let customerInfo = try await Purchases.shared.customerInfo()
        let entitlements = await customerInfo.entitlements.all.asPurchasedEntitlement
        return entitlements
    }
    
    @MainActor
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        let products = await Purchases.shared.products(productIds)
        return products.map({ AnyProduct(revenueCatProduct: $0) })
    }
    
    func onRestorePurchase() async throws -> [PurchasedEntitlement] {
        let customerInfo = try await Purchases.shared.restorePurchases()
        let entitlements = await customerInfo.entitlements.all.asPurchasedEntitlement
        return entitlements
    }
    
    func onPurchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        let products = await Purchases.shared.products([productId])
        
        guard let product = products.first else {
            throw PurchaseError.productNotFount
        }
        
        let result = try await Purchases.shared.purchase(product: product)
        let customerInfo = result.customerInfo
        let entitlements = await customerInfo.entitlements.all.asPurchasedEntitlement
        return entitlements
    }
    
    func logIn(userId: String) async throws -> [PurchasedEntitlement] {
        let (customerInfo, _) = try await Purchases.shared.logIn(userId)
        let entitlements = await customerInfo.entitlements.all.asPurchasedEntitlement
        return entitlements
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        if let email = attributes.email {
            Purchases.shared.attribution.setEmail(attributes.email)
        }
    }
    
    func logOut() async throws {
        let _ = try await Purchases.shared.logOut()
    }
}

struct PurchaseProfileAttributes: Codable {
    var email: String?
    
    enum CodingKeys: String, CodingKey {
        case email
    }
    
    var eventParameters: [String: Any] {
        var dict: [String: Any?] = [
            "PurAtr_\(CodingKeys.email.rawValue)": email
        ]
        
        return dict.compactMapValues({ $0 })
    }
}
