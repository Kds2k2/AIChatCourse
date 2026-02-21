//
//  PurchaseManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 21.02.2026.
//

import SwiftUI
import Foundation

protocol PurchaseService: Sendable {
    func listenForTransactions(onTransactionsUpdated: @escaping @Sendable ([PurchasedEntitlement]) async -> Void) async
    func getUserEntitlements() async -> [PurchasedEntitlement]
}

struct MockPurchaseService: PurchaseService {
    
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []) {
        self.activeEntitlements = activeEntitlements
    }
    
    func listenForTransactions(onTransactionsUpdated: @escaping @Sendable ([PurchasedEntitlement]) async -> Void) {
        Task {
            await onTransactionsUpdated(activeEntitlements)
        }
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
        activeEntitlements
    }
}

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
                
                let entitlements = await self.getUserEntitlements()
                await onTransactionsUpdated(entitlements)
                
                await transaction.finish()
            }
        }
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
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
}
    
@MainActor
@Observable
final class PurchaseManager {
    
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
            updateActiveEntitlements(entitlements)
        }
        
        Task {
            await service.listenForTransactions { [weak self] updatedEntitlements in
                guard let self else { return }
                await self.updateActiveEntitlements(updatedEntitlements)
            }
        }
    }
    
    private func updateActiveEntitlements(_ entitlements: [PurchasedEntitlement]) {
        self.entitlements = entitlements.sortedByKeyPath(keyPath: \.expirationDateCalc, order: .ascending)
        logManager?.addUserProperties(dict: self.entitlements.eventParameters, isHighPriority: false)
    }
}
