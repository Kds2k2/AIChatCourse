//
//  AvatarService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 14.01.2026.
//

import SwiftUI

protocol RemoteAvatarService: Sendable {
    func createAvatart(avatar: AvatarModel, image: UIImage) async throws
    func getAvatar(id: String) async throws -> AvatarModel
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
    func getAvatarsForUser(userId: String) async throws -> [AvatarModel]
    func incrementAvatarClickCount(avatarId: String) async throws
}
