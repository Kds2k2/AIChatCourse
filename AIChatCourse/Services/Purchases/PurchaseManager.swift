//
//  PurchaseManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 21.02.2026.
//

import SwiftUI
import Foundation

protocol PurchaseService: Sendable {
    func listenForTransactions(onTransactionsUpdated: @Sendable ([PurchasedEntitlement]) async -> Void) async
    func getUserEntitlements() async -> [PurchasedEntitlement]
}

struct MockPurchaseService: PurchaseService {
    
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []) {
        self.activeEntitlements = activeEntitlements
    }
    
    func listenForTransactions(onTransactionsUpdated: ([PurchasedEntitlement]) async -> Void) async {
        await onTransactionsUpdated(activeEntitlements)
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
        return activeEntitlements
    }
}

import StoreKit
struct StoreKitPurchaseService: PurchaseService {
    
    func listenForTransactions(onTransactionsUpdated: ([PurchasedEntitlement]) async -> Void) async {
        for await update in StoreKit.Transaction.updates {
            if let transaction = try? update.payloadData {
                let entitlements = await getUserEntitlements()
                await onTransactionsUpdated(entitlements)
                await transaction.finish()
            }
        }
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
        var activeTransactions: [PurchasedEntitlement] = []
        
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            
            switch verificationResult {
            case .verified(let transaction):
                let isActive: Bool
                if let expirationDate = transaction.expirationDate {
                    isActive = expirationDate >= Date.now
                } else {
                    isActive = transaction.revocationDate == nil
                }
                
                activeTransactions
                    .append(
                        PurchasedEntitlement(
                            productId: transaction.productID,
                            expirationDate: transaction.expirationDate,
                            isActive: isActive,
                            originalPurchaseDate: transaction.originalPurchaseDate,
                            latestPurchaseDate: transaction.purchaseDate,
                            ownershipType: EntitlementOwnershipOption(type: transaction.ownershipType),
                            isSandbox: transaction.environment == .sandbox,
                            isVerified: true
                        )
                    )
            case .unverified:
                break
            }
        }
        
        return activeTransactions
    }
}

@MainActor
@Observable
class PurchaseManager {
    
    private let service: PurchaseService
    private let logManager: LogManager?
    
    private(set) var entitlements: [PurchasedEntitlement] = []
    
    init(service: PurchaseService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.configure()
    }
    
    private func configure() {
        Task {
            let entitlements = await service.getUserEntitlements()
            await updateActiveEntitlements(entitlements: entitlements)
        }
        
        Task {
            await service.listenForTransactions { updatedEntitlements in
                await updateActiveEntitlements(entitlements: updatedEntitlements)
            }
        }
    }
    
    private func updateActiveEntitlements(entitlements: [PurchasedEntitlement]) {
        self.entitlements = entitlements.sortedByKeyPath(keyPath: \.expirationDateCalc, order: .ascending)
        logManager?.addUserProperties(dict: self.entitlements.eventParameters, isHighPriority: false)
    }
}
