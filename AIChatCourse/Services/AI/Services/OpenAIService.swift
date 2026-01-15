//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 13.01.2026.
//

import SwiftUI
import OpenAI

struct OpenAIService: AIService {
    
    var openAI: OpenAI {
        OpenAI(apiToken: AppKeys.openAI)
    }
    
    func generateImage(input: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: input,
            model: .gpt_image_1,
            n: 1,
            quality: .low,
            size: ._1024,
            user: nil
        )
        
        let result = try await openAI.images(query: query)
        
        guard
            let base64 = result.data.first?.b64Json,
            let data = Data(base64Encoded: base64),
            let image = UIImage(data: data)
        else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        let messages = chats.compactMap({ $0.toOpenAIModel() })
        let query = ChatQuery(messages: messages, model: .gpt4_o_mini)
        let result = try await openAI.chats(query: query)
        
        guard
            let chat = result.choices.first?.message,
            let model = AIChatModel(chat: chat)
        else {
            throw OpenAIError.invalidResponse
        }
        
        return model
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}

struct AIChatModel: Hashable {
    let role: AIChatRole
    let message: String
    
    init(role: AIChatRole, message: String) {
        self.role = role
        self.message = message
    }
    
    init?(chat: ChatResult.Choice.Message) {
        self.role = AIChatRole(rawRole: chat.role)
        
        if let content = chat.content {
            self.message = content
        } else {
            return nil
        }
    }
    
    func toOpenAIModel() -> ChatQuery.ChatCompletionMessageParam? {
        ChatQuery.ChatCompletionMessageParam(
            role: role.openAIRole,
            content: message
        )
    }
}

enum AIChatRole: Hashable {
    case system, user, assistant, tool, developer
    
    init(role: ChatQuery.ChatCompletionMessageParam.Role) {
        switch role {
        case .system:
            self = .system
        case .user:
            self = .user
        case .assistant:
            self = .assistant
        case .tool:
            self = .tool
        case .developer:
            self = .developer
        }
    }
    
    init(rawRole: String) {
        let role = ChatQuery.ChatCompletionMessageParam.Role(rawValue: rawRole)
        switch role {
        case .system:
            self = .system
        case .user:
            self = .user
        case .assistant:
            self = .assistant
        case .tool:
            self = .tool
        case .none:
            self = .system
        case .some(.developer):
            self = .developer
        }
    }
    
    var openAIRole: ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .system:
            return .system
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .tool:
            return .tool
        case .developer:
            return .developer
        }
    }
}
