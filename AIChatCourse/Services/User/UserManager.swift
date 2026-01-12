//
//  UserManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.01.2026.
//

import SwiftUI

protocol UserService: Sendable {
    func saveUser(user: UserModel) async throws
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
}

struct MockUserService: UserService {
    
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

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: UserService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        try await collection.setDocument(document: user)
    }
    
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
    }
    
    func deleteUser(userId: String) async throws {
        try await collection.deleteDocument(id: userId)
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }
}

@MainActor
@Observable
class UserManager {
    
    private let service: UserService
    private(set) var currentUser: UserModel?
    private var streamUserTask: Task<Void, Never>?
    
    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? AppInfo.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await service.saveUser(user: user)
        startUserStream(userId: auth.uid)
    }
    
    func signOut() {
        stopUserStream()
        currentUser = nil
    }
    
    func deleleCurrentUser() async throws {
        let uid = try currentUserId()
        try await service.deleteUser(userId: uid)
        signOut()
    }
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await service.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
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
                for try await userUpdate in service.streamUser(userId: userId) {
                    self.currentUser = userUpdate
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
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
