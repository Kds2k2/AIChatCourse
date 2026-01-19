//
//  MockChatService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 17.01.2026.
//

import SwiftUI

struct MockChatService: ChatService, MockService {
    
    let chats: [ChatModel]
    let delay: Double
    let showError: Bool

    init(chats: [ChatModel] = ChatModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.chats = chats
        self.delay = delay
        self.showError = showError
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await executionBehavior()
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await executionBehavior()
        return chats.first { chat in
            return chat.userId == userId && chat.avatarId == avatarId
        }
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await executionBehavior()
        return chats.shuffled()
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
        try await executionBehavior()
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await executionBehavior()
        return ChatMessageModel.mocks.randomElement()
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(ChatMessageModel.mocks.filter({ $0.chatId == chatId }))
        }
    }
    
    func deleteChat(chatId: String) async throws {
        try await executionBehavior()
    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        try await executionBehavior()
    }
    
    func reportChat(report: ChatReportModel) async throws {
        try await executionBehavior()
    }
}
