//
//  CustomPaywallView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 22.02.2026.
//

import SwiftUI

struct CustomPaywallView: View {
    
    var products: [AnyProduct] = []
    var title: String = "Try premium today!"
    var subtitle: String = "Unlock unlimited access and exclusive feature for premium members."
    
    var onRestorePurchaseButtonPressed: () -> Void = { }
    var onBackButtonPressed: () -> Void = { }
    var onPurchaseProduct: (AnyProduct) -> Void = { _ in }
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                VStack(spacing: 24) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Text(subtitle)
                        .font(.subheadline)
                }
                .foregroundStyle(.white)
                .padding(40)
                
                VStack(spacing: 8) {
                    ForEach(products) { product in
                        productRow(product: product)
                    }
                    
                    Text("Already have a subscription?\nRestore Purchase")
                        .font(.callout)
                        .fontWeight(.medium)
                        .underline()
                        .foregroundStyle(.white)
                        .anyButton(.plain) {
                            onRestorePurchaseButtonPressed()
                        }
                        .padding(16)
                }
                
                Spacer(minLength: 0)
                Spacer(minLength: 0)
            }
        }
        .multilineTextAlignment(.center)
        .overlay(alignment: .topLeading) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.white)
                .font(.title)
                .padding(8)
                .tappableBackground()
                .anyButton {
                    onBackButtonPressed()
                }
                .padding(16)
        }
    }
    
    // MARK: - Views
    private func productRow(product: AnyProduct) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title)
                        .font(.headline)
                    Text(product.priceStringWithDuration)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("START")
                    .badgeButton()
            }
            
            Divider()
            Text(product.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
        .anyButton(.press) {
            onPurchaseProduct(product)
        }
        .padding(16)
    }
}

#Preview {
    CustomPaywallView(products: AnyProduct.mocks)
}
