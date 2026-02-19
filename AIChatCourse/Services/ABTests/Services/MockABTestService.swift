//
//  MockABTestService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 19.02.2026.
//

import SwiftUI

class MockABTestService: ABTestService {
    var activeTests: ActiveABTests
    
    init(createAccountTest: Bool? = nil, onboardingCommunityTest: Bool? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
}
