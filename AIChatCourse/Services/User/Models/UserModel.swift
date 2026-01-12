//
//  UserModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 04.01.2026.
//
import SwiftUI
import Foundation
import IdentifiableByString

struct UserModel: Codable, Hashable, StringIdentifiable {

    var id: String { userId }
    
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let createdAt: Date?
    let lastSignInAt: Date?
    
    let creationVersion: String?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        createdAt: Date? = nil,
        lastSignInAt: Date? = nil,
        creationVersion: String? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.createdAt = createdAt
        self.lastSignInAt = lastSignInAt
        self.creationVersion = creationVersion
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    init(auth: UserAuthInfo, creationVersion: String?) {
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            createdAt: auth.createdAt,
            lastSignInAt: auth.lastSignInAt,
            creationVersion: creationVersion
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case createdAt = "created_at"
        case lastSignInAt = "last_sign_in_at"
        case creationVersion = "creating_version"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
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
                userId: "user1",
                createdAt: now.addingTimeInterval(days: -5),
                didCompleteOnboarding: false,
                profileColorHex: "#9F2B68"
            ),
            UserModel(
                userId: UUID().uuidString,
                createdAt: now.addingTimeInterval(days: -2),
                didCompleteOnboarding: true,
                profileColorHex: "#FF5733"
            ),
            UserModel(
                userId: UUID().uuidString,
                createdAt: now.addingTimeInterval(days: -1),
                didCompleteOnboarding: false,
                profileColorHex: "#FF5733"
            )
        ]
    }
}
