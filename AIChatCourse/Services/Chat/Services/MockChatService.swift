//
//  MockChatService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 17.01.2026.
//

import SwiftUI

struct MockChatService: ChatService, MockService {
    let delay: Double
    let showError: Bool

    init(delay: Double = 0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    func createNewChat(chat: ChatModel) async throws {
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await executionBehavior()
        return ChatModel.mock
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(ChatMessageModel.mocks)
        }
    }
}
