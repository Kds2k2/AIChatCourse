//
//  UserManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.01.2026.
//

import SwiftUI

@MainActor
@Observable
class UserManager {
    
    private let remote: RemoteUserService
    private let local: LocalUserPersistance
    
    private(set) var currentUser: UserModel?
    private var streamUserTask: Task<Void, Never>?
    
    init(services: UserServices) {
        self.remote = services.remote
        self.local = services.local
        self.currentUser = local.getCurrentUser()
    }
    
    // MARK: - Remote
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? AppInfo.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await remote.saveUser(user: user)
        startUserStream(userId: auth.uid)
    }
     
    func signOut() {
        stopUserStream()
        currentUser = nil
    }
    
    func deleleCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
        signOut()
    }
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }
    
    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    
    private func startUserStream(userId: String) {
        streamUserTask?.cancel()
        
        streamUserTask = Task {
            do {
                for try await userUpdate in remote.streamUser(userId: userId) {
                    self.currentUser = userUpdate
                    self.saveCurrentUserLocal()
                    print("Successfully listened to user: \(userUpdate.userId)")
                }
            } catch {
                print("Stream encountered an error: \(error)")
                self.currentUser = nil
            }
        }
    }
    
    private func stopUserStream() {
        streamUserTask?.cancel()
        streamUserTask = nil
    }
    
    // MARK: - Local
    private func saveCurrentUserLocal() {
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                print("Success save user localy.")
            } catch {
                print("Error saving user localy: \(error)")
            }
        }
    }
    
    // MARK: - Error
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
