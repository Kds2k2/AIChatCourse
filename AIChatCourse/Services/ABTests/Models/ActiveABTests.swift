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
    
    init(
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOption
    ) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.categoryRowTest = categoryRowTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202602_CreateAccTest"
        case onboardingCommunityTest = "_202602_OnbCommunityTest"
        case categoryRowTest = "_202602_CategoryRowTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "ab_test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "ab_test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "ab_test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue
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
    }
    
    var asNSObjectDictionary: [String: NSObject]? {
        [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSObject
        ]
    }
}
