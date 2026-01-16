//
//  ChatBubbleViewBuilder.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 05.01.2026.
//

import SwiftUI

struct ChatBubbleViewBuilder: View {
    
    var message: ChatMessageModel = .mock
    var isCurrentUser: Bool = false
    var currentUserProfileColor: Color = .accent
    var imageName: String?
    var onImagePressed: (() -> Void)?
    
    var body: some View {
        ChatBubbleView(
            text: message.content?.message ?? "",
            textColor: isCurrentUser ? .white : .primary,
            backgroundColor: isCurrentUser ? currentUserProfileColor : Color(uiColor: .systemGray6),
            imageName: imageName,
            showImage: !isCurrentUser,
            onImagePressed: onImagePressed
        )
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(.leading, isCurrentUser ? 75 : 0)
        .padding(.trailing, isCurrentUser ? 0 : 75)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(isCurrentUser: true, currentUserProfileColor: .blue)
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(isCurrentUser: true)
        }
        .padding(8)
    }
}
