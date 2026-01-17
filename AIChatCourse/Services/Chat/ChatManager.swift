//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 16.01.2026.
//

import SwiftUI

@MainActor
@Observable
class ChatManager {
    
    private var service: ChatService
    
    init(service: ChatService) {
        self.service = service
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
        try await service.addChatMessage(message: message)
    }
}
