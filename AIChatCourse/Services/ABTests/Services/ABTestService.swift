//
//  ABTestService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 19.02.2026.
//

import SwiftUI

@MainActor
protocol ABTestService: Sendable {
    var activeTests: ActiveABTests { get }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
    func fetchUpdatedConfig() async throws -> ActiveABTests
}
