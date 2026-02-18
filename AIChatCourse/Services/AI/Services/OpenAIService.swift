//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 13.01.2026.
//

import SwiftUI
import FirebaseFunctions

struct OpenAIService: AIService {
    
//    /// DEPRECATED
//    /// Direct call by API_KEY
//    func generateImage(input: String) async throws -> UIImage {
//        let query = ImagesQuery(
//            prompt: input,
//            model: .gpt_image_1,
//            n: 1,
//            quality: .low,
//            size: ._1024,
//            user: nil
//        )
//        
//        let result = try await openAI.images(query: query)
//        
//        guard
//            let base64 = result.data.first?.b64Json,
//            let data = Data(base64Encoded: base64),
//            let image = UIImage(data: data)
//        else {
//            throw OpenAIError.invalidResponse
//        }
//        
//        return image
//    }
    
    func generateImage(input: String) async throws -> UIImage {
        let response = try await Functions
            .functions(region: "europe-west1")
            .httpsCallable("generateOpenAIImage")
            .call(["input": input])

        guard
            let base64 = response.data as? String,
            let data = Data(base64Encoded: base64),
            let image = UIImage(data: data)
        else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
       
//    /// DEPRECATED
//    /// Direct call by API_KEY
//    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
//        let messages = chats.compactMap({ $0.toOpenAIModel() })
//        let query = ChatQuery(messages: messages, model: .gpt4_o_mini)
//        let result = try await openAI.chats(query: query)
//        
//        guard
//            let chat = result.choices.first?.message,
//            let model = AIChatModel(chat: chat)
//        else {
//            throw OpenAIError.invalidResponse
//        }
//        
//        return model
//    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        let messages = chats.compactMap { chat in
            let role = chat.role.rawValue
            let content = chat.message
            return [
                "role": role,
                "content": content
            ]
        }
        
        let response = try await Functions
            .functions(region: "europe-west1")
            .httpsCallable("generateOpenAIText")
            .call(["messages": messages])
        
        guard
            let dict = response.data as? [String: Any],
            let roleString = dict["role"] as? String,
            let role = AIChatRole(rawValue: roleString),
            let content = dict["content"] as? String else {
            throw OpenAIError.invalidResponse
        }
        
        return AIChatModel(role: role, message: content)
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}

struct AIChatModel: Hashable, Codable {
    let role: AIChatRole
    let message: String
    
    init(role: AIChatRole, message: String) {
        self.role = role
        self.message = message
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case message
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "aiChatMessage_\(CodingKeys.role.rawValue)": role.rawValue,
            "aiChatMessage_\(CodingKeys.message.rawValue)": message
        ]
        
        return dict.compactMapValues({ $0 })
    }
}

enum AIChatRole: String, Hashable, Codable {
    case system, user, assistant, tool, developer
}
