//
//  ActiveABTests.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 19.02.2026.
//

import SwiftUI
import FirebaseRemoteConfig

struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    private(set) var categoryRowTest: CategoryRowTestOption
    private(set) var paywallTest: PaywallTestOption
    
    init(
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOption,
        paywallTest: PaywallTestOption
    ) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.categoryRowTest = categoryRowTest
        self.paywallTest = paywallTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202602_CreateAccTest"
        case onboardingCommunityTest = "_202602_OnbCommunityTest"
        case categoryRowTest = "_202602_CategoryRowTest"
        case paywallTest = "_202602_PaywallTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "ab_test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "ab_test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "ab_test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue,
            "ab_test\(CodingKeys.paywallTest.rawValue)": paywallTest.rawValue
        ]
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
    
    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
    
    mutating func update(categoryRowTest newValue: CategoryRowTestOption) {
        categoryRowTest = newValue
    }
    
    mutating func update(paywallTest newValue: PaywallTestOption) {
        paywallTest = newValue
    }
}

extension ActiveABTests {
    init(config: RemoteConfig) {
        self.createAccountTest = config.configValue(forKey: ActiveABTests.CodingKeys.createAccountTest.rawValue).boolValue
        
        self.onboardingCommunityTest = config.configValue(forKey: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue).boolValue
        
        let categoryRowTestString = config.configValue(forKey: ActiveABTests.CodingKeys.categoryRowTest.rawValue).stringValue
        if let categoryRowTest = CategoryRowTestOption(rawValue: categoryRowTestString) {
            self.categoryRowTest = categoryRowTest
        } else {
            self.categoryRowTest = .default
        }
        
        let paywallTestString = config.configValue(forKey: ActiveABTests.CodingKeys.paywallTest.rawValue).stringValue
        if let paywallTest = PaywallTestOption(rawValue: paywallTestString) {
            self.paywallTest = paywallTest
        } else {
            self.paywallTest = .default
        }
    }
    
    var asNSObjectDictionary: [String: NSObject]? {
        [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSObject,
            CodingKeys.paywallTest.rawValue: paywallTest.rawValue as NSObject
        ]
    }
}
