//
//  ChatModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//
import Foundation

struct ChatModel: Identifiable, Hashable {
    
    let id: String
    let userId: String
    let avatarId: String
    let createdAt: Date
    let updatedAt: Date
    
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
