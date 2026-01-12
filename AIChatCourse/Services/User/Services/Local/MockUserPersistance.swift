//
//  MockUserPersistance.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.01.2026.
//

import SwiftUI

struct MockUserPersistance: LocalUserPersistance {
    
    let currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func getCurrentUser() -> UserModel? {
        currentUser
    }
    
    func saveCurrentUser(user: UserModel?) throws {
    }
}
