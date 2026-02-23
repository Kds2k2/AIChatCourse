//
//  PurchaseManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 21.02.2026.
//

import SwiftUI
import Foundation

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
            if let entitlements = try? await service.getUserEntitlements() {
                updateActiveEntitlements(entitlements)
            }
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
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        logManager?.trackEvent(event: Event.getProductsStart(productIds: productIds))
        do {
            let products = try await service.getProducts(productIds: productIds)
            logManager?.trackEvent(event: Event.getProductsSuccess)
            return products
        } catch {
            logManager?.trackEvent(event: Event.getProductsFail(error: error))
            throw error
        }
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        logManager?.trackEvent(event: Event.restorePurchaseStart)
        do {
            let entitlements = try await service.onRestorePurchase()
            logManager?.trackEvent(event: Event.restorePurchaseSuccess(purchasedEntitlement: entitlements))
            updateActiveEntitlements(entitlements)
            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.restorePurchaseFail(error: error))
            throw error
        }
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        logManager?.trackEvent(event: Event.purchaseStart(productId: productId))
        do {
            let entitlements = try await service.onPurchaseProduct(productId: productId)
            logManager?.trackEvent(event: Event.purchaseSuccess(purchasedEntitlement: entitlements))
            updateActiveEntitlements(entitlements)
            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.purchaseFail(error: error))
            throw error
        }
    }
    
    @discardableResult
    func logIn(userId: String, attributes: PurchaseProfileAttributes? = nil) async throws -> [PurchasedEntitlement] {
        logManager?.trackEvent(event: Event.logInStart(userId: userId))
        do {
            let entitlements = try await service.logIn(userId: userId)
            logManager?.trackEvent(event: Event.logInSuccess(purchasedEntitlement: entitlements))
            updateActiveEntitlements(entitlements)
            
            if let attributes {
                try await service.updateProfileAttributes(attributes: attributes)
            }
            
            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.logInFail(error: error))
            throw error
        }
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        try await service.updateProfileAttributes(attributes: attributes)
    }
    
    func logOut() async throws {
        do {
            try await service.logOut()
            entitlements.removeAll()
            configure()
            
            logManager?.trackEvent(event: Event.logOutSuccess)
        } catch {
            logManager?.trackEvent(event: Event.logOutFail(error: error))
            throw error
        }
    }
    
    enum Event: LoggableEvent {
        case purchaseStart(productId: String), purchaseSuccess(purchasedEntitlement: [PurchasedEntitlement]), purchaseFail(error: Error)
        case restorePurchaseStart, restorePurchaseSuccess(purchasedEntitlement: [PurchasedEntitlement]), restorePurchaseFail(error: Error)
        case getProductsStart(productIds: [String]), getProductsSuccess, getProductsFail(error: Error)
        case logInStart(userId: String), logInSuccess(purchasedEntitlement: [PurchasedEntitlement]), logInFail(error: Error)
        case updateProfileAttributes(attributes: PurchaseProfileAttributes)
        case logOutSuccess, logOutFail(error: Error)
        
        var eventName: String {
            switch self {
            case .purchaseStart:                    return "PurMan_Purchase_Start"
            case .purchaseSuccess:                  return "PurMan_Purchase_Success"
            case .purchaseFail:                     return "PurMan_Purchase_Fail"
            case .restorePurchaseStart:             return "PurMan_RestorePurchase_Start"
            case .restorePurchaseSuccess:           return "PurMan_RestorePurchase_Success"
            case .restorePurchaseFail:              return "PurMan_RestorePurchase_Fail"
            case .getProductsStart:                 return "PurMan_GetProducts_Start"
            case .getProductsSuccess:               return "PurMan_GetProducts_Success"
            case .getProductsFail:                  return "PurMan_GetProducts_Fail"
            case .logInStart:                       return "PurMan_LogIn_Start"
            case .logInSuccess:                     return "PurMan_LogIn_Success"
            case .logInFail:                        return "PurMan_LogIn_Fail"
            case .updateProfileAttributes:          return "PurMan_UpdateProfileAttributes"
            case .logOutSuccess:                    return "PurMan_LogOut_Success"
            case .logOutFail:                       return "PurMan_LogOut_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseStart(productId: let productId):
                return ["product_id": productId]
            case .getProductsStart(productIds: let productIds):
                return ["product_ids": productIds]
            case .purchaseSuccess(purchasedEntitlement: let entitlements), .restorePurchaseSuccess(purchasedEntitlement: let entitlements), .logInSuccess(purchasedEntitlement: let entitlements):
                return entitlements.eventParameters
            case .purchaseFail(error: let error), .getProductsFail(error: let error), .restorePurchaseFail(error: let error), .logInFail(error: let error), .logOutFail(error: let error):
                return error.eventParameters
            case .logInStart(userId: let userId):
                return ["userId": userId]
            case .updateProfileAttributes(attributes: let attributes):
                return attributes.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .purchaseFail, .getProductsFail, .restorePurchaseFail, .logInFail, .logOutFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
