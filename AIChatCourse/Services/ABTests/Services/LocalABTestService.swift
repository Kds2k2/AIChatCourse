//
//  LocalABTestService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 19.02.2026.
//

import SwiftUI

class LocalABTestService: ABTestService {
    
    @UserDefault(key: ActiveABTests.CodingKeys.createAccountTest.rawValue, startingValue: .random())
    private var createAccountTest: Bool
    
    @UserDefault(key: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue, startingValue: .random())
    private var onboardingCommunityTest: Bool
    
    @UserDefault(key: ActiveABTests.CodingKeys.categoryRowTest.rawValue, startingValue: .random())
    private var categoryRowTest: CategoryRowTestOption
    
    var activeTests: ActiveABTests {
        ActiveABTests(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest,
            categoryRowTest: categoryRowTest
        )
    }
    
    init() { }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        createAccountTest = updatedTests.createAccountTest
        onboardingCommunityTest = updatedTests.onboardingCommunityTest
        categoryRowTest = updatedTests.categoryRowTest
    }
}
