//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 18.02.2026.
//

import SwiftUI

@MainActor
@Observable
class ABTestManager {
    
    private let service: ABTestService
    private var logManager: LogManager?
    
    var activeTests: ActiveABTests
    
    init(service: ABTestService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.activeTests = service.activeTests
        self.configure()
    }
    
    private func configure() {
        activeTests = service.activeTests
        logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: true)
    }
    
    func override(updateTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updateTests)
        self.configure()
    }
}
