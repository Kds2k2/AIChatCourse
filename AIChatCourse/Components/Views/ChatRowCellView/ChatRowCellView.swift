//
//  ChatRowCellView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 03.01.2026.
//

import SwiftUI

struct ChatRowCellView: View {
    var imageName: String? = Constants.randomImage
    var headline: String? = "Alpha"
    var subheadline: String? = "This is the last message in the chat."
    var hasNewChat: Bool = true
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                if let imageName {
                    ImageLoaderView(urlString: imageName)
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
                }
                
                if let subheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if hasNewChat {
                Text("NEW")
                    .badgeButton()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    ZStack {
        Color.gray
        
        List {
            ChatRowCellView()
                
            ChatRowCellView(hasNewChat: false)
                
            ChatRowCellView(headline: nil)
                
            ChatRowCellView(subheadline: nil)
                
        }
    }
    .ignoresSafeArea()
}
