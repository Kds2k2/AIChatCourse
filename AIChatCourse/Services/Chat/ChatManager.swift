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
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await service.getChat(userId: userId, avatarId: avatarId)
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
        try await service.addChatMessage(message: message)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        service.streamChatMessages(chatId: chatId)
    }
}
