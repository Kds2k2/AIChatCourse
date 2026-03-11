//
//  PaywallView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 21.02.2026.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    
    @State var viewModel: PaywallViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            switch viewModel.paywallTest {
            case .storeKit:
                StoreKitPaywallView(
                    productIds: viewModel.productIds,
                    onInAppPurchaseStart: viewModel.onPurchaseStart,
                    onInAppPurchaseCompletion: { product, result in
                        viewModel.onPurchaseCompletion(product: product, result: result) {
                            dismiss()
                        }
                    }
                )
            case .revenueCat:
                RevenueCatPaywallView()
            case .custom:
                if viewModel.products.isEmpty {
                    ProgressView()
                } else {
                    CustomPaywallView(
                        products: viewModel.products,
                        onRestorePurchaseButtonPressed: {
                            viewModel.onRestorePurchaseButtonPressed {
                                dismiss()
                            }
                        },
                        onBackButtonPressed: {
                            viewModel.onBackButtonPressed {
                                dismiss()
                            }
                        },
                        onPurchaseProduct: { product in
                            viewModel.onPurchaseProduct(product: product) {
                                dismiss()
                            }
                        }
                    )
                }
            }
        }
        .screenAppearAnalytics(name: "PaywallView")
        .showCustomAlert(alert: $viewModel.showAlert)
        .task {
            await viewModel.loadProducts()
        }
    }
}

#Preview("Custom") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .custom)))
    
    return PaywallView(viewModel: PaywallViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("StoreKit") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .storeKit)))
    
    return PaywallView(viewModel: PaywallViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("RevenueCat") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .revenueCat)))
    
    return PaywallView(viewModel: PaywallViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}
