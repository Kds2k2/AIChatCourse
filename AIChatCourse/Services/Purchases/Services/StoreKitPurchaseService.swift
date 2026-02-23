//
//  StoreKitPurchaseService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 23.02.2026.
//

import SwiftUI
import StoreKit

actor StoreKitPurchaseService: PurchaseService {
    
    private var transactionListenerTask: Task<Void, Never>?
    
    init() {}
    
    deinit {
        transactionListenerTask?.cancel()
    }
    
    func listenForTransactions(onTransactionsUpdated: @escaping @Sendable ([PurchasedEntitlement]) async -> Void) {
        transactionListenerTask?.cancel()
        
        transactionListenerTask = Task {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                if let entitlements = try? await self.getUserEntitlements() {
                    await onTransactionsUpdated(entitlements)
                }
                
                await transaction.finish()
            }
        }
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        var activeEntitlements: [PurchasedEntitlement] = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            // Transaction.currentEntitlements already filters expired,
            // but we defensively double-check revocation.
            guard transaction.revocationDate == nil else {
                continue
            }
            
            let entitlement = await PurchasedEntitlement(
                id: transaction.id.description,
                productId: transaction.productID,
                expirationDate: transaction.expirationDate,
                isActive: true,
                originalPurchaseDate: transaction.originalPurchaseDate,
                latestPurchaseDate: transaction.purchaseDate,
                ownershipType: EntitlementOwnershipOption(type: transaction.ownershipType),
                isSandbox: transaction.environment == .sandbox,
                isVerified: true
            )
            
            activeEntitlements.append(entitlement)
        }
        
        return activeEntitlements
    }
    
    @MainActor
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        let products = try await Product.products(for: productIds)
        return products.compactMap({ AnyProduct(storeKitProduct: $0) })
    }
    
    func onRestorePurchase() async throws -> [PurchasedEntitlement] {
        try await AppStore.sync()
        return try await getUserEntitlements()
    }
    
    func onPurchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        let products = try await Product.products(for: [productId])
        
        guard let product = products.first else {
            throw PurchaseError.productNotFount
        }
        
        let result = try await product.purchase()
        switch result {
        case .success(let verificationResult):
            let transaction = try verificationResult.payloadValue
            await transaction.finish()
            
            return try await getUserEntitlements()
        case .userCancelled:
            throw PurchaseError.userCancelledPurchase
        default:
            throw PurchaseError.failedToPurchase
        }
    }
    
    func logIn(userId: String) async throws -> [PurchasedEntitlement] {
        try await getUserEntitlements()
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        
    }
    
    func logOut() async throws {
        
    }
}
