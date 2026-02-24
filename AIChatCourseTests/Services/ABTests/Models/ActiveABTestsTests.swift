//
//  ActiveABTestsTests.swift
//  AIChatCourseTests
//
//  Created by Dmitro Kryzhanovsky on 24.02.2026.
//

import Testing
@testable import AIChatCourse
import Foundation

@MainActor
struct ActiveABTestsTests {

    private func randomBool() -> Bool {
        Bool.random()
    }
    
    private func randomCategoryOption() -> CategoryRowTestOption {
        CategoryRowTestOption.allCases.randomElement() ?? .default
    }
    
    private func randomPaywallOption() -> PaywallTestOption {
        PaywallTestOption.allCases.randomElement() ?? .default
    }
    
    private func randomActiveTests() -> ActiveABTests {
        ActiveABTests(
            createAccountTest: randomBool(),
            onboardingCommunityTest: randomBool(),
            categoryRowTest: randomCategoryOption(),
            paywallTest: randomPaywallOption()
        )
    }
    
    // MARK: - MockABTestService Tests
    
    @Test("Initializer should use provided values")
    func initializerUsesProvidedValues() async throws {
        let createAccount = randomBool()
        let onboarding = randomBool()
        let category = randomCategoryOption()
        let paywall = randomPaywallOption()
        
        let service = MockABTestService(
            createAccountTest: createAccount,
            onboardingCommunityTest: onboarding,
            categoryRowTest: category,
            paywallTest: paywall
        )
        
        let result = try await service.fetchUpdatedConfig()
        
        #expect(result.createAccountTest == createAccount)
        #expect(result.onboardingCommunityTest == onboarding)
        #expect(result.categoryRowTest == category)
        #expect(result.paywallTest == paywall)
    }
    
    @Test("Initializer should fallback to default values when nil provided")
    func initializerFallsBackToDefaults() async throws {
        let service = MockABTestService()
        let result = try await service.fetchUpdatedConfig()
        
        #expect(result.createAccountTest == false)
        #expect(result.onboardingCommunityTest == false)
        #expect(result.categoryRowTest == .default)
        #expect(result.paywallTest == .default)
    }
    
    @Test("saveUpdatedConfig should update activeTests")
    func saveUpdatedConfigUpdatesState() async throws {
        let service = MockABTestService()
        let newConfig = randomActiveTests()
        
        try service.saveUpdatedConfig(updatedTests: newConfig)
        
        let fetched = try await service.fetchUpdatedConfig()
        
        #expect(fetched.createAccountTest == newConfig.createAccountTest)
        #expect(fetched.onboardingCommunityTest == newConfig.onboardingCommunityTest)
        #expect(fetched.categoryRowTest == newConfig.categoryRowTest)
        #expect(fetched.paywallTest == newConfig.paywallTest)
    }
    
    @Test("fetchUpdatedConfig should always return current activeTests state")
    func fetchAlwaysReturnsLatestState() async throws {
        let service = MockABTestService()
        
        let firstConfig = randomActiveTests()
        try service.saveUpdatedConfig(updatedTests: firstConfig)
        
        let secondConfig = randomActiveTests()
        try service.saveUpdatedConfig(updatedTests: secondConfig)
        
        let fetched = try await service.fetchUpdatedConfig()
        
        #expect(fetched.createAccountTest == secondConfig.createAccountTest)
        #expect(fetched.onboardingCommunityTest == secondConfig.onboardingCommunityTest)
        #expect(fetched.categoryRowTest == secondConfig.categoryRowTest)
        #expect(fetched.paywallTest == secondConfig.paywallTest)
    }

    // MARK: - Tests
    
    @Test("Initializer should correctly assign all properties")
    func initializerAssignsProperties() {
        let createAccount = randomBool()
        let onboarding = randomBool()
        let category = randomCategoryOption()
        let paywall = randomPaywallOption()
        
        let model = ActiveABTests(
            createAccountTest: createAccount,
            onboardingCommunityTest: onboarding,
            categoryRowTest: category,
            paywallTest: paywall
        )
        
        #expect(model.createAccountTest == createAccount)
        #expect(model.onboardingCommunityTest == onboarding)
        #expect(model.categoryRowTest == category)
        #expect(model.paywallTest == paywall)
    }
    
    @Test("Mutating update methods should change respective properties")
    func updateMethodsChangeValues() {
        var model = ActiveABTests(
            createAccountTest: randomBool(),
            onboardingCommunityTest: randomBool(),
            categoryRowTest: randomCategoryOption(),
            paywallTest: randomPaywallOption()
        )
        
        let newCreateAccount = randomBool()
        let newOnboarding = randomBool()
        let newCategory = randomCategoryOption()
        let newPaywall = randomPaywallOption()
        
        model.update(createAccountTest: newCreateAccount)
        model.update(onboardingCommunityTest: newOnboarding)
        model.update(categoryRowTest: newCategory)
        model.update(paywallTest: newPaywall)
        
        #expect(model.createAccountTest == newCreateAccount)
        #expect(model.onboardingCommunityTest == newOnboarding)
        #expect(model.categoryRowTest == newCategory)
        #expect(model.paywallTest == newPaywall)
    }
    
    @Test("Codable should correctly encode and decode with custom keys")
    func codableEncodesAndDecodesProperly() throws {
        let model = ActiveABTests(
            createAccountTest: randomBool(),
            onboardingCommunityTest: randomBool(),
            categoryRowTest: randomCategoryOption(),
            paywallTest: randomPaywallOption()
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(model)
        let decoded = try decoder.decode(ActiveABTests.self, from: data)
        
        #expect(decoded.createAccountTest == model.createAccountTest)
        #expect(decoded.onboardingCommunityTest == model.onboardingCommunityTest)
        #expect(decoded.categoryRowTest == model.categoryRowTest)
        #expect(decoded.paywallTest == model.paywallTest)
    }
    
    @Test("eventParameters should contain correct prefixed keys and raw values")
    func eventParametersContainCorrectValues() {
        let model = ActiveABTests(
            createAccountTest: randomBool(),
            onboardingCommunityTest: randomBool(),
            categoryRowTest: randomCategoryOption(),
            paywallTest: randomPaywallOption()
        )
        
        let params = model.eventParameters
        
        #expect(params["ab_test_202602_CreateAccTest"] as? Bool == model.createAccountTest)
        #expect(params["ab_test_202602_OnbCommunityTest"] as? Bool == model.onboardingCommunityTest)
        #expect(params["ab_test_202602_CategoryRowTest"] as? String == model.categoryRowTest.rawValue)
        #expect(params["ab_test_202602_PaywallTest"] as? String == model.paywallTest.rawValue)
    }
    
    @Test("asNSObjectDictionary should return dictionary with correct NSObject values")
    func asNSObjectDictionaryReturnsCorrectValues() {
        let model = ActiveABTests(
            createAccountTest: randomBool(),
            onboardingCommunityTest: randomBool(),
            categoryRowTest: randomCategoryOption(),
            paywallTest: randomPaywallOption()
        )
        
        let dictionary = model.asNSObjectDictionary
        
        #expect(dictionary?["_202602_CreateAccTest"] as? Bool == model.createAccountTest)
        #expect(dictionary?["_202602_OnbCommunityTest"] as? Bool == model.onboardingCommunityTest)
        #expect(dictionary?["_202602_CategoryRowTest"] as? String == model.categoryRowTest.rawValue)
        #expect(dictionary?["_202602_PaywallTest"] as? String == model.paywallTest.rawValue)
    }
}
