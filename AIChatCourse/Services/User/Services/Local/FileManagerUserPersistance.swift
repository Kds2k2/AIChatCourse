//
//  FileManagerUserPersistance.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.01.2026.
//

import SwiftUI

struct FileManagerUserPersistance: LocalUserPersistance {
    
    private let userDocumentKey = "current_user"
    
    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentKey)
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
}
