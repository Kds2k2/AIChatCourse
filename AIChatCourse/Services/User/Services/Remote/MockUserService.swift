//
//  MockUserService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.01.2026.
//

import SwiftUI

struct MockUserService: RemoteUserService, MockService {
    
    let currentUser: UserModel?
    let delay: Double
    let showError: Bool
    
    init(user: UserModel? = nil, delay: Double = 0, showError: Bool = false) {
        self.currentUser = user
        self.delay = delay
        self.showError = showError
    }
    
    func saveUser(user: UserModel) async throws {
    }
    
    func deleteUser(userId: String) async throws {
    }
    
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }
}
