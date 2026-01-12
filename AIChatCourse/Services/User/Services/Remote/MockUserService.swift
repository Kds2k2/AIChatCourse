//
//  MockUserService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.01.2026.
//

import SwiftUI

struct MockUserService: RemoteUserService {
    
    let currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
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
