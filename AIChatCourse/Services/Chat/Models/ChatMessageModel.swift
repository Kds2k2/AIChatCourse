//
//  ChatMessageModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//

import Foundation
import IdentifiableByString

struct ChatMessageModel: StringIdentifiable, Hashable, Codable {
    let id: String
    let chatId: String
    let authorId: String?
    let content: AIChatModel?
    let seenByIds: [String]?
    let createdAt: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: AIChatModel? = nil,
        seenByIds: [String]? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.createdAt = createdAt
    }
    
    var createdAtCalculated: Date {
        createdAt ?? .distantPast
    }
    
    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds else { return true }
        return seenByIds.contains(userId)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case authorId = "author_id"
        case content
        case seenByIds = "seen_by_ids"
        case createdAt = "created_at"
    }
    
    static func newUserMessage(chatId: String, userId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: userId,
            content: message,
            seenByIds: [userId],
            createdAt: .now
        )
    }
    
    static func newAIMessage(chatId: String, avatarId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: avatarId,
            content: message,
            seenByIds: [],
            createdAt: .now
        )
    }
    
    static func newTypingAIMessage() -> ChatMessageModel {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: "typing_chat_id",
            authorId: nil,
            content: nil,
            createdAt: Date(),
        )
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var emptyMock: Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: "1",
            authorId: "",
            content: AIChatModel(role: .assistant, message: ""),
            seenByIds: nil,
            createdAt: Date().addingTimeInterval(minutes: -1)
        )
    }
    
    static var mocks: [Self] {
        let now = Date()
        
        return [
            ChatMessageModel(
                id: UUID().uuidString,
                chatId: "chat1",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .user, message: "Hey! How are you?"),
                seenByIds: [UserAuthInfo.mock().uid, "user2", "user3"],
                createdAt: now.addingTimeInterval(days: -1, minutes: -10)
            ),
            ChatMessageModel(
                id: UUID().uuidString,
                chatId: "chat2",
                authorId: AvatarModel.mock.avatarId,
                content: AIChatModel(role: .assistant, message: "I'm good 🙂 How about you?"),
                seenByIds: [UserAuthInfo.mock().uid],
                createdAt: now.addingTimeInterval(days: -1, minutes: -7)
            ),
            ChatMessageModel(
                id: UUID().uuidString,
                chatId: "chat3",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .user, message: "Doing great! Working on the app."),
                seenByIds: [UserAuthInfo.mock().uid, "user2", "user3"],
                createdAt: now.addingTimeInterval(days: -1, minutes: -3)
            ),
            ChatMessageModel(
                id: UUID().uuidString,
                chatId: "chat1",
                authorId: AvatarModel.mock.avatarId,
                content: AIChatModel(role: .assistant, message: "Nice 🚀 Can’t wait to see it."),
                seenByIds: nil,
                createdAt: now.addingTimeInterval(minutes: -1)
            )
        ]
    }
}
