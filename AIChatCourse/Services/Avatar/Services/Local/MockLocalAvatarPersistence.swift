//
//  MockLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 15.01.2026.
//

import SwiftUI

@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    func addRecentAvatar(avatar: AvatarModel) throws {
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
}
