//
//  MockAIService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 13.01.2026.
//

import SwiftUI

struct MockAIService: AIService {
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        return UIImage(systemName: "star.fill")!
    }
}
