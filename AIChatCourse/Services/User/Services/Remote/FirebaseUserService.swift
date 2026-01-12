//
//  FirebaseUserService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.01.2026.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: RemoteUserService {
    
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
