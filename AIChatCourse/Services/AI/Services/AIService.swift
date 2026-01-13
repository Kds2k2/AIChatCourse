//
//  AIService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 13.01.2026.
//

import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
}
