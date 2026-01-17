//
//  ChatBubbleIndicatorView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 17.01.2026.
//

import SwiftUI

struct ChatBubbleIndicatorView: View {
    @State private var scale: CGFloat = 0.5

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { _ in
                Circle()
                    .frame(width: 8, height: 8)
                    .scaleEffect(scale)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(),
                        value: scale
                    )
            }
        }
        .padding(12)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(6)
        .onAppear {
            scale = 1
        }
    }
}

#Preview {
    ChatBubbleIndicatorView()
}
