//
//  MockService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 17.01.2026.
//

import Foundation

protocol MockService {
    var delay: Double { get }
    var showError: Bool { get }
}

extension MockService {
    internal func executionBehavior() async throws {
        try await Task.sleep(for: .seconds(delay))
        if showError {
            throw URLError(.unknown)
        }
    }
}
