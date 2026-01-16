//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 16.01.2026.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
    }
}

struct FirebaseChatService: ChatService {
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await collection.setDocument(document: chat)
    }
}

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
}
