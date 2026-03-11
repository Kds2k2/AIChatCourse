//
//  PaywallViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.03.2026.
//

import SwiftUI
import StoreKit

@MainActor
protocol PaywallInteractor {
    var activeTests: ActiveABTests { get }
    
    func trackEvent(event: LoggableEvent)
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
}

extension CoreInteractor: PaywallInteractor { }

@Observable
@MainActor
class PaywallViewModel {
    let interactor: PaywallInteractor
    
    private(set) var products: [AnyProduct] = []
    private(set) var productIds: [String] = EntitlementOption.allProductIds
    
    var showAlert: AnyAppAlert?
    
    var paywallTest: PaywallTestOption {
        interactor.activeTests.paywallTest
    }
    
    init(interactor: PaywallInteractor) {
        self.interactor = interactor
    }
    
    func loadProducts() async {
        interactor.trackEvent(event: Event.loadProductsStart)
        do {
            self.products = try await interactor.getProducts(productIds: productIds)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    func onRestorePurchaseButtonPressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.restorePurchaseStart)
        Task {
            do {
                let entitlements = try await interactor.restorePurchase()
                
                if entitlements.hasActiveEntitlement {
                    onDismiss()
                }
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onBackButtonPressed(onDismiss: () -> Void) {
        interactor.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }
    
    func onPurchaseProduct(product: AnyProduct, onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.purchaseProductStart(product: product))
        Task {
            do {
                let entitlements = try await interactor.purchaseProduct(productId: product.id)
                
                interactor.trackEvent(event: Event.purchaseStart(product: product))
                if entitlements.hasActiveEntitlement {
                    onDismiss()
                }
            } catch {
                interactor.trackEvent(event: Event.purchaseFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        interactor.trackEvent(event: Event.purchaseStart(product: product))
    }
    
    func onPurchaseCompletion(product: StoreKit.Product, result: Result<StoreKit.Product.PurchaseResult, any Error>, onDismiss: () -> Void) {
        let product = AnyProduct(storeKitProduct: product)
        
        switch result {
        case .success(let value):
            switch value {
            case .success:
                interactor.trackEvent(event: Event.purchaseSuccess(product: product))
                onDismiss()
            case .pending:
                interactor.trackEvent(event: Event.purchasePending(product: product))
            case .userCancelled:
                interactor.trackEvent(event: Event.purchaseUserCancelled(product: product))
            default:
                interactor.trackEvent(event: Event.purchaseUnknown(product: product))
            }
        case .failure(let error):
            interactor.trackEvent(event: Event.purchaseFail(error: error))
        }
    }
    
    // MARK: - Events
    enum Event: LoggableEvent {
        case purchaseStart(product: AnyProduct)
        case purchaseSuccess(product: AnyProduct)
        case purchasePending(product: AnyProduct)
        case purchaseUserCancelled(product: AnyProduct)
        case purchaseUnknown(product: AnyProduct)
        case purchaseFail(error: Error)
        case loadProductsStart
        case purchaseProductStart(product: AnyProduct)
        case restorePurchaseStart
        case backButtonPressed
        
        var eventName: String {
            switch self {
            case .purchaseStart:            "PaywallView_Purchase_Start"
            case .purchaseSuccess:          "PaywallView_Purchase_Success"
            case .purchasePending:          "PaywallView_Purchase_Pending"
            case .purchaseUserCancelled:    "PaywallView_Purchase_UserCancelled"
            case .purchaseUnknown:          "PaywallView_Purchase_Unknown"
            case .purchaseFail:             "PaywallView_Purchase_Fail"
            case .loadProductsStart:        "PaywallView_LoadProducts_Start"
            case .purchaseProductStart:     "PaywallView_PurchaseProducts_Start"
            case .restorePurchaseStart:     "PaywallView_RestoreProducts_Start"
            case .backButtonPressed:        "PaywallView_BackButton_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseFail(error: let error):
                return error.eventParameters
            case .purchasePending(product: let product), .purchaseStart(product: let product), .purchaseSuccess(product: let product), .purchaseUnknown(product: let product), .purchaseUserCancelled(product: let product), .purchaseProductStart(product: let product):
                return product.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .purchaseFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
