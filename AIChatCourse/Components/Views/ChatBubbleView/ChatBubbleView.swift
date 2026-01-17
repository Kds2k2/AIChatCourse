//
//  ChatBubbleView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 05.01.2026.
//

import SwiftUI

struct ChatBubbleView: View {

    var text: String = "Some text."
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray6)
    
    var imageName: String?
    let imageOffset: CGFloat = 14
    var showImage: Bool = true
    
    var onImagePressed: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top) {
            if showImage {
                ZStack {
                    if let imageName {
                        ImageLoaderView(urlString: imageName)
                            .anyButton {
                                onImagePressed?()
                            }
                    } else {
                        Rectangle()
                            .fill(.secondary)
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .offset(y: imageOffset)
            }
            
            if text.isEmpty {
                ChatBubbleIndicatorView()
            } else {
                Text(text)
                    .font(.body)
                    .foregroundStyle(textColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(backgroundColor)
                    .cornerRadius(6)
            }
        }
        .padding(.bottom, showImage ? imageOffset : 0)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ChatBubbleView()
            ChatBubbleView(text: "Some fksjal;kfjsl;akfjl;akflakfjalkfalskfjsalkfjsalkfjslakfjalkfjslakfjalfkjsalkfalkfjalfksjal;fjalsfkalfkjsal;f.")
            
            ChatBubbleView(
                textColor: .white,
                backgroundColor: .accent,
                imageName: nil,
                showImage: false
            )
            ChatBubbleView(
                text: "Some fksjal;kfjsl;akfjl;akflakfjalkfalskfjsalkfjsalkfjslakfjalkfjslakfjalfkjsalkfalkfjalfksjal;fjalsfkalfkjsal;f.",
                textColor: .white,
                backgroundColor: .accent,
                imageName: nil,
                showImage: false
            )
        }
        .padding(8)
    }
}
