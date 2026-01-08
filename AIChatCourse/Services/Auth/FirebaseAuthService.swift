//
//  FirebaseAuthService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 08.01.2026.
//

import SwiftUI
import FirebaseAuth

extension EnvironmentValues {
    @Entry var authService: FirebaseAuthService = FirebaseAuthService()
}

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
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.createdAt = user.metadata.creationDate
        self.lastSignInAt = user.metadata.lastSignInDate
    }
}

struct FirebaseAuthService {
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        
        return nil
    }
    
    func singInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        let user = UserAuthInfo(user: result.user)
        let isNewUser = result.additionalUserInfo?.isNewUser ?? true
        
        return (user, isNewUser)
    }
}
