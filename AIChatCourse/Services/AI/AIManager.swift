//
//  AIManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 13.01.2026.
//

import SwiftUI
import Foundation

@MainActor
@Observable
class AIManager {
    
    private let service: AIService
    
    init(service: AIService) {
        self.service = service
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
}
