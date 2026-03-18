//
//  LocalChatRowCell.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 16.03.2026.
//

import SwiftUI

struct LocalChatRowCell: View {
    var imageName: String? = "qwen"
    var headline: String? = "Alpha"
    var subheadline: String? = "This is the last message in the chat."
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                if let imageName {
                    Image(imageName)
                        .resizable()
                } else {
                    Rectangle()
                        .fill(.accent)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                if let headline {
                    Text(headline)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                }
                
                if let subheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(1)
                }
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview("Default") {
    ZStack {
        Color.gray
        
        List {
            LocalChatRowCell()
            
            LocalChatRowCell(headline: nil)
                
            LocalChatRowCell(subheadline: nil)
                
        }
    }
    .ignoresSafeArea()
}

#Preview("Without formatting") {
    ZStack {
        Color.gray
        
        List {
            LocalChatRowCell()
                .removeListRowFormatting()
            
            LocalChatRowCell(headline: nil)
                .removeListRowFormatting()
            
            LocalChatRowCell(subheadline: nil)
                .removeListRowFormatting()
        }
    }
    .ignoresSafeArea()
}
