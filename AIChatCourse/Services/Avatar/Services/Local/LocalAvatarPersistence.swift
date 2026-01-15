//
//  LocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 15.01.2026.
//

import SwiftUI

@MainActor
protocol LocalAvatarPersistence: Sendable {
    func addRecentAvatar(avatar: AvatarModel) throws
    func getRecentAvatars() throws -> [AvatarModel]
}
