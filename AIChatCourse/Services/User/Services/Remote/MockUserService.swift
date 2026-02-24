//
//  MockUserService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.01.2026.
//

import SwiftUI
import Combine

@MainActor
class MockUserService: RemoteUserService, MockService {
    
    var currentUser: UserModel?
    let delay: Double
    let showError: Bool
    
    init(user: UserModel? = nil, delay: Double = 0, showError: Bool = false) {
        self.currentUser = user
        self.delay = delay
        self.showError = showError
    }
    
    func saveUser(user: UserModel) async throws {
        currentUser = user
    }
    
    func deleteUser(userId: String) async throws {
        currentUser = nil
    }
    
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        guard let currentUser else {
            throw URLError(.unknown)
        }
        
        self.currentUser = UserModel(
            userId: currentUser.userId,
            email: currentUser.email,
            isAnonymous: currentUser.isAnonymous,
            createdAt: currentUser.createdAt,
            lastSignInAt: currentUser.lastSignInAt,
            creationVersion: currentUser.creationVersion,
            didCompleteOnboarding: true,
            profileColorHex: profileColorHex
        )
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }
}
