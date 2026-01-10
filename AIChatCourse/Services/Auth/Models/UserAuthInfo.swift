//
//  UserAuthInfo.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 08.01.2026.
//

import SwiftUI

struct UserAuthInfo {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let createdAt: Date?
    let lastSignInAt: Date?
    
    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        createdAt: Date? = nil,
        lastSignInAt: Date? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.createdAt = createdAt
        self.lastSignInAt = lastSignInAt
    }
    
    static func mock(isAnonymous: Bool = false) -> Self {
        return isAnonymous ? mocks[0] : mocks[1]
    }
    
    static var mocks: [Self] {
        return [
            // Anonymous user
            UserAuthInfo(
                uid: "anon_001",
                email: nil,
                isAnonymous: true,
                createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 3), // 3 days ago
                lastSignInAt: Date().addingTimeInterval(-60 * 10) // 10 min ago
            ),
            
            // Registered user (email)
            UserAuthInfo(
                uid: "user_001",
                email: "john.doe@example.com",
                isAnonymous: false,
                createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 30), // 30 days ago
                lastSignInAt: Date().addingTimeInterval(-60 * 60 * 2) // 2 hours ago
            ),
            
            // Registered user (older account)
            UserAuthInfo(
                uid: "user_002",
                email: "jane.smith@example.com",
                isAnonymous: false,
                createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 180), // 6 months ago
                lastSignInAt: Date().addingTimeInterval(-60 * 60 * 24 * 1) // 1 day ago
            )
        ]
    }

}
