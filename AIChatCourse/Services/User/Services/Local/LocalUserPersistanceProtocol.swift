//
//  LocalUserPersistance.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 12.01.2026.
//

import SwiftUI

protocol LocalUserPersistance: Sendable {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
