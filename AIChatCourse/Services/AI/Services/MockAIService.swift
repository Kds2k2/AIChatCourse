//
//  MockAIService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 13.01.2026.
//

import SwiftUI

struct MockAIService: AIService, MockService {
    
    let delay: Double
    let showError: Bool
    
    init(delay: Double = 0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await executionBehavior()
        return UIImage(systemName: "star.fill")!
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await executionBehavior()
        return AIChatModel(role: .assistant, message: "This is returned text form the AI.")
    }
}
