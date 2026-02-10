//
//  MockAuthService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.01.2026.
//

import SwiftUI
import AuthenticationServices

struct MockAuthService: AuthService, MockService {
    let currentUser: UserAuthInfo?
    let delay: Double
    let showError: Bool
    
    init(user: UserAuthInfo? = nil, delay: Double = 0, showError: Bool = false) {
        self.currentUser = user
        self.delay = delay
        self.showError = showError
    }
    
    func addAuthenticatedListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
        }
    }
    
    func removeAuthenticatedListener(listener: any NSObjectProtocol) {
        
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        return currentUser
    }
    
    func singInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await executionBehavior()
        let user = UserAuthInfo.mock(isAnonymous: true)
        return (user, true)
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await executionBehavior()
        let user = UserAuthInfo.mock(isAnonymous: false)
        return (user, false)
    }
    
    func signInWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await executionBehavior()
        let user = UserAuthInfo.mock(isAnonymous: false)
        return (user, false)
    }
    
    func signUpWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await executionBehavior()
        let user = UserAuthInfo.mock(isAnonymous: false)
        return (user, false)
    }
    
    func signOut() throws {
        
    }
    
    func deleteAccount() async throws {
        
    }
}
