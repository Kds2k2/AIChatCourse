//
//  ChatReportModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 19.01.2026.
//

import SwiftUI
import IdentifiableByString

struct ChatReportModel: Codable, StringIdentifiable {
    let id: String
    let userId: String
    let chatId: String
    let isActive: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case chatId = "chat_id"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
    
    static func new(chatId: String, userId: String) -> Self {
        ChatReportModel(
            id: UUID().uuidString,
            userId: userId,
            chatId: chatId,
            isActive: true,
            createdAt: .now
        )
    }
}
