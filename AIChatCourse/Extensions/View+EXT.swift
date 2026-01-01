//
//  View+EXT.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

extension View {
    func callToActionButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(.accent)
            .cornerRadius(16)
    }
    
    func tappableBackground() -> some View {
        background(Color.black.opacity(0.001))
    }
}
