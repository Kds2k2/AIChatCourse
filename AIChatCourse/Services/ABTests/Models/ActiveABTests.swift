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

enum CategoryRowTestOption: String, Codable, CaseIterable, Identifiable {
    case original, top, hidden
    
    var id: String { self.rawValue }
    
    static var `default`: Self { .original }
    
    static func random() -> CategoryRowTestOption {
        CategoryRowTestOption.allCases.randomElement() ?? .original
    }
}
