//
//  ChatMessageModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//

import Foundation

struct ChatMessageModel {
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let seenByIds: [String]?
    let createdAt: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: String? = nil,
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
    
    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds else { return true }
        return seenByIds.contains(userId)
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        
        return [
            ChatMessageModel(
                id: UUID().uuidString,
                chatId: "1",
                authorId: "user1",
                content: "Hey! How are you?",
                seenByIds: ["user2", "user3"],
                createdAt: now.addingTimeInterval(days: -1, minutes: -10)
            ),
            ChatMessageModel(
                id: UUID().uuidString,
                chatId: "2",
                authorId: "user2",
                content: "I'm good 🙂 How about you?",
                seenByIds: ["user1"],
                createdAt: now.addingTimeInterval(days: -1, minutes: -7)
            ),
            ChatMessageModel(
                id: UUID().uuidString,
                chatId: "3",
                authorId: "user3",
                content: "Doing great! Working on the app.",
                seenByIds: ["user1", "user2", "user4"],
                createdAt: now.addingTimeInterval(days: -1, minutes: -3)
            ),
            ChatMessageModel(
                id: UUID().uuidString,
                chatId: "1",
                authorId: "user1",
                content: "Nice 🚀 Can’t wait to see it.",
                seenByIds: nil,
                createdAt: now.addingTimeInterval(minutes: -1)
            )
        ]
    }
}
