//
//  UserModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 04.01.2026.
//
import Foundation
import SwiftUI

struct UserModel {
    let userId: String
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    let createdAt: Date?
    
    init(
        userId: String,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil,
        createdAt: Date? = nil,
    ) {
        self.userId = userId
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
        self.createdAt = createdAt
    }
    
    var profileColorCalculated: Color {
        guard let profileColorHex else {
            return .accent
        }
        
        return Color(hex: profileColorHex)
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(
                userId: UUID().uuidString,
                didCompleteOnboarding: false,
                profileColorHex: "#9F2B68",
                createdAt: now.addingTimeInterval(days: -5)
            ),
            UserModel(
                userId: UUID().uuidString,
                didCompleteOnboarding: true,
                profileColorHex: "#FF5733",
                createdAt: now.addingTimeInterval(days: -2)
            ),
            UserModel(
                userId: UUID().uuidString,
                didCompleteOnboarding: false,
                profileColorHex: "#FF5733",
                createdAt: now.addingTimeInterval(days: -1)
            )
        ]
    }
}
