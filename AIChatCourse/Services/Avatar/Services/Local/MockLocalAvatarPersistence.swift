//
//  MockLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 15.01.2026.
//

import SwiftUI

@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    
    let avatars: [AvatarModel]
    
    init(avatars: [AvatarModel] = AvatarModel.mocks) {
        self.avatars = avatars
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws {
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        return avatars.shuffled()
    }
}
