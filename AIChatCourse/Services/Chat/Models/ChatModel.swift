//
//  ChatModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//
import Foundation
import IdentifiableByString

struct ChatModel: Hashable, Codable, StringIdentifiable {
    
    let id: String
    let userId: String
    let avatarId: String
    let createdAt: Date
    let updatedAt: Date
    
    static func createNewChat(userId: String, avatarId: String) -> Self {
        ChatModel(
            id: "\(userId).\(avatarId)",
            userId: userId,
            avatarId: avatarId,
            createdAt: .now,
            updatedAt: .now
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avatarId = "avatar_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatModel(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                avatarId: UUID().uuidString,
                createdAt: now,
                updatedAt: now
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                avatarId: UUID().uuidString,
                createdAt: now.addingTimeInterval(days: -3),
                updatedAt: now.addingTimeInterval(days: -2, hours: -1)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                avatarId: UUID().uuidString,
                createdAt: now.addingTimeInterval(days: -1),
                updatedAt: now.addingTimeInterval(hours: -5)
            )
        ]
    }
}
