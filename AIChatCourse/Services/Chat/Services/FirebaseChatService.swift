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
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
//        let result: [ChatModel] = try await collection
//            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
//            .whereField(ChatModel.CodingKeys.avatarId.rawValue, isEqualTo: avatarId)
//            .getAllDocuments()
//        
//        return result.first
        
        try await collection.getDocument(id: ChatModel.chatId(userId: userId, avatarId: avatarId))
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        return try await collection
            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
            .getAllDocuments()
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
        try await messagesCollection(chatId: message.chatId).setDocument(document: message)
        try await collection.updateDocument(id: message.chatId, dict: [
            ChatModel.CodingKeys.updatedAt.rawValue: Date.now
        ])
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        let messages: [ChatMessageModel] = try await messagesCollection(chatId: chatId)
            .order(by: ChatMessageModel.CodingKeys.createdAt.rawValue, descending: true)
            .limit(to: 1)
            .getAllDocuments()
        
        return messages.first
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        messagesCollection(chatId: chatId).streamAllDocuments()
    }
}
