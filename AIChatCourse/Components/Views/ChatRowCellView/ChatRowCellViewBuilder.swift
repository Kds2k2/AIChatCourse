//
//  ChatRowCellViewBuilder.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 03.01.2026.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {

    var chat: ChatModel = .mock
    var currentUserId: String? = ""
    
    @State private var avatar: AvatarModel?
    @State private var didLoadAvatar: Bool = false
    var getAvatar: () async -> AvatarModel?
    
    @State private var lastChatMessage: ChatMessageModel?
    @State private var didLoadChatMessage: Bool = false
    var getLastChatMessage: () async -> ChatMessageModel?
    
    private var isLoading: Bool {
        (didLoadAvatar && didLoadChatMessage) ? false : true
    }
    
    private var subheadline: String? {
        if isLoading {
            return "xxxx xxxx xxxx xxxx"
        }
        
        if avatar == nil && lastChatMessage == nil {
            return "Error"
        }
        
        return lastChatMessage?.content?.message
    }
    
    var body: some View {
        ChatRowCellView(
            imageName: avatar?.profileImageName,
            headline: isLoading ? "xxxx xxxx" : avatar?.name,
            subheadline: subheadline,
            hasNewChat: isLoading ? false : hasNewChat
        )
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            avatar = await getAvatar()
            didLoadAvatar = true
        }
        .task {
            lastChatMessage = await getLastChatMessage()
            didLoadChatMessage = true
        }
    }
    
    private var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserId else { return false }
        return lastChatMessage.hasBeenSeenBy(userId: currentUserId)
    }
}

#Preview {
    VStack {
        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
            try? await Task.sleep(for: .seconds(5))
            return .mock
        }, getLastChatMessage: {
            try? await Task.sleep(for: .seconds(5))
            return .mock
        })
        
        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
            try? await Task.sleep(for: .seconds(10))
            return .mock
        }, getLastChatMessage: {
            try? await Task.sleep(for: .seconds(10))
            return .mock
        })
        
        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
            nil
        }, getLastChatMessage: {
            nil
        })
    }
}
