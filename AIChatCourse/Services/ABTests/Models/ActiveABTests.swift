//
//  ActiveABTests.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 19.02.2026.
//

import SwiftUI

struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    
    init(createAccountTest: Bool, onboardingCommunityTest: Bool) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202602_CreateAccTest"
        case onboardingCommunityTest = "_202602_OnbCommunityTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "ab_test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "ab_test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest
        ]
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
    
    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
}
