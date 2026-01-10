//
//  FirebaseAuthService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 08.01.2026.
//

import SwiftUI
import FirebaseAuth

struct FirebaseAuthService: AuthService {
    
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
            
            onListenerAttached(listener)
        }
    }
    
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
    
    func signInWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        if let user = Auth.auth().currentUser, user.isAnonymous {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            try await user.delete()
            return result.asAuthInfo
        }

        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.asAuthInfo
    }
    
    func signUpWithEmailAndPassword(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        
        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: password
        )
        
        if let user = Auth.auth().currentUser, user.isAnonymous {
            let result = try await user.link(with: credential)
            return result.asAuthInfo
        }
        
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.asAuthInfo
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFount
        }
        
        try await user.delete()
    }
    
    enum AuthError: LocalizedError {
        case userNotFount
        
        var errorDescription: String? {
            switch self {
            case .userNotFount:
                return "Current Authenticated user not found."
            }
        }
    }
}

extension AuthDataResult {
    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        return (user, isNewUser)
    }
}
