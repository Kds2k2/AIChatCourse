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
    
    static func chatId(userId: String, avatarId: String) -> String {
        return "\(userId).\(avatarId)"
    }
    
    static func new(userId: String, avatarId: String) -> Self {
        ChatModel(
            id: chatId(userId: userId, avatarId: avatarId),
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
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "chat_\(CodingKeys.id.rawValue)": id,
            "chat_\(CodingKeys.userId.rawValue)": userId,
            "chat_\(CodingKeys.avatarId.rawValue)": avatarId,
            "chat_\(CodingKeys.createdAt.rawValue)": createdAt,
            "chat_\(CodingKeys.updatedAt.rawValue)": updatedAt,
        ]
        
        return dict.compactMapValues({ $0 })
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatModel(
                id: "chat1",
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mock.avatarId,
                createdAt: now,
                updatedAt: now
            ),
            ChatModel(
                id: "chat2",
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                createdAt: now,
                updatedAt: now
            ),
            ChatModel(
                id: "chat3",
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                createdAt: now.addingTimeInterval(days: -3),
                updatedAt: now.addingTimeInterval(days: -2, hours: -1)
            ),
            ChatModel(
                id: "chat4",
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                createdAt: now.addingTimeInterval(days: -1),
                updatedAt: now.addingTimeInterval(hours: -5)
            )
        ]
    }
}
