//
//  PaywallView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 21.02.2026.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var products: [AnyProduct] = []
    @State private var productIds: [String] = EntitlementOption.allProductIds
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        ZStack {
            if products.isEmpty {
                ProgressView()
            } else {
                CustomPaywallView(
                    products: products,
                    onRestorePurchaseButtonPressed: onRestorePurchaseButtonPressed,
                    onBackButtonPressed: onBackButtonPressed,
                    onPurchaseProduct: onPurchaseProduct
                )
            }
        }
        .screenAppearAnalytics(name: "PaywallView_Custom")
        .showCustomAlert(alert: $showAlert)
        .task {
            await loadProducts()
        }
        
//        StoreKitPaywallView(
//            productIds: productIds,
//            onInAppPurchaseStart: onPurchaseStart,
//            onInAppPurchaseCompletion: onPurchaseCompletion
//        )
//        .screenAppearAnalytics(name: "PaywallView_StoreKit")
    }
    
    private func loadProducts() async {
        logManager.trackEvent(event: Event.loadProductsStart)
        do {
            self.products = try await purchaseManager.getProducts(productIds: productIds)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    private func onRestorePurchaseButtonPressed() {
        logManager.trackEvent(event: Event.restorePurchaseStart)
        Task {
            do {
                let entitlements = try await purchaseManager.restorePurchase()
                
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
    
    private func onPurchaseProduct(product: AnyProduct) {
        logManager.trackEvent(event: Event.purchaseProductStart(product: product))
        Task {
            do {
                let entitlements = try await purchaseManager.purchaseProduct(productId: product.id)
                
                logManager.trackEvent(event: Event.purchaseStart(product: product))
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                logManager.trackEvent(event: Event.purchaseFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        logManager.trackEvent(event: Event.purchaseStart(product: product))
    }
    
    private func onPurchaseCompletion(product: StoreKit.Product, result: Result<StoreKit.Product.PurchaseResult, any Error>) {
        let product = AnyProduct(storeKitProduct: product)
        
        switch result {
        case .success(let value):
            switch value {
            case .success:
                logManager.trackEvent(event: Event.purchaseSuccess(product: product))
                dismiss()
            case .pending:
                logManager.trackEvent(event: Event.purchasePending(product: product))
            case .userCancelled:
                logManager.trackEvent(event: Event.purchaseUserCancelled(product: product))
            default:
                logManager.trackEvent(event: Event.purchaseUnknown(product: product))
            }
        case .failure(let error):
            logManager.trackEvent(event: Event.purchaseFail(error: error))
        }
    }
    
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

#Preview {
    PaywallView()
        .previewEnvironment()
}
