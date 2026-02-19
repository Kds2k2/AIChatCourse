//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 18.02.2026.
//

import SwiftUI

struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    
    init(createAccountTest: Bool) {
        self.createAccountTest = createAccountTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202602_CreateAccTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "ab_test\(CodingKeys.createAccountTest.rawValue)": createAccountTest
        ]
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
}

protocol ABTestService {
    var activeTests: ActiveABTests { get }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
}

class MockABTestService: ABTestService {
    var activeTests: ActiveABTests
    
    init(createAccountTest: Bool? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
}

class LocalABTestService: ABTestService {
    
    @UserDefault(key: ActiveABTests.CodingKeys.createAccountTest.rawValue, startingValue: .random())
    private var createAccountTest: Bool
    
    var activeTests: ActiveABTests {
        ActiveABTests(createAccountTest: createAccountTest)
    }
    
    init() {
        // 
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        createAccountTest = updatedTests.createAccountTest
    }
}

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
