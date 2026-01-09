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
}
