//
//  PaywallView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 21.02.2026.
//

import SwiftUI

enum EntitlementOption: Codable, CaseIterable {
    case yearly
    
    var productId: String {
        switch self {
        case .yearly: return "DimaKryzhanovsky.AIChatCourse.Yearly"
        }
    }
    
    static var allProductIds: [String] {
        EntitlementOption.allCases.map({ $0.productId })
    }
}

struct PaywallView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        StoreKitPaywallView(
            onInAppPurchaseStart: onPurchaseStart,
            onInAppPurchaseCompletion: onPurchaseCompletion
        )
        .screenAppearAnalytics(name: "PaywallView")
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
        
        var eventName: String {
            switch self {
            case .purchaseStart:            "PaywallView_Purchase_Start"
            case .purchaseSuccess:          "PaywallView_Purchase_Success"
            case .purchasePending:          "PaywallView_Purchase_Pending"
            case .purchaseUserCancelled:    "PaywallView_Purchase_UserCancelled"
            case .purchaseUnknown:          "PaywallView_Purchase_Unknown"
            case .purchaseFail:             "PaywallView_Purchase_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseFail(error: let error):
                return error.eventParameters
            case .purchasePending(product: let product), .purchaseStart(product: let product), .purchaseSuccess(product: let product), .purchaseUnknown(product: let product), .purchaseUserCancelled(product: let product):
                return product.eventParameters
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

import StoreKit
struct StoreKitPaywallView: View {
    
    var onInAppPurchaseStart: ((Product) async -> Void)?
    var onInAppPurchaseCompletion: ((Product, Result<Product.PurchaseResult, any Error>) async -> Void)?
    
    var body: some View {
        SubscriptionStoreView(productIDs: EntitlementOption.allProductIds) {
            VStack(spacing: 8) {
                Text("AI Chat 😎")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text("Get premium access to unlock all features.")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .containerBackground(Color.accent.gradient, for: .subscriptionStore)
        }
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStoreControlStyle(.prominentPicker)
        .onInAppPurchaseStart(perform: onInAppPurchaseStart)
        .onInAppPurchaseCompletion(perform: onInAppPurchaseCompletion)
    }
}

#Preview {
    PaywallView()
        .previewEnvironment()
}
