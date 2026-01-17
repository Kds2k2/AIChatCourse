//
//  FirebaseChatService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 17.01.2026.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: ChatService {
    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messagesCollection(chatId: String) -> CollectionReference {
        collection.document(chatId).collection("messages")
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await collection.setDocument(document: chat)
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
        try await messagesCollection(chatId: message.chatId).setDocument(document: message)
        try await collection.updateDocument(id: message.chatId, dict: [
            ChatModel.CodingKeys.updatedAt.rawValue: Date.now
        ])
    }
}
