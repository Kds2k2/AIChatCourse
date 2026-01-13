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
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}
