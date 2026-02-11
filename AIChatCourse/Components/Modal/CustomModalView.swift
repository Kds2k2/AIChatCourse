//
//  CustomModalView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.02.2026.
//

import SwiftUI

struct CustomModalView: View {
    
    var title: String = "Title"
    var subtitle: String? = "Subtitle"
    var primaryButtonTitle: String = "Yes"
    var primaryButtonAction: () -> Void = { }
    var secondaryButtonTitle: String = "No"
    var secondaryButtonAction: () -> Void = { }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(spacing: 8) {
                Text(primaryButtonTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .anyButton(.press) { primaryButtonAction() }
                
                Text(secondaryButtonTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .tappableBackground()
                    .anyButton { secondaryButtonAction() }
            }
        }
        .multilineTextAlignment(.center)
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(40)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: { },
            secondaryButtonTitle: "No",
            secondaryButtonAction: { }
        )
    }
}
