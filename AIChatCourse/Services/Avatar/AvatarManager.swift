//
//  AvatarManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 14.01.2026.
//

import SwiftUI
import Foundation

@MainActor
@Observable
class AvatarManager {
    
    private let remote: RemoteAvatarService
    private let local: LocalAvatarPersistence
    private(set) var avatars: AvatarModel?
    
    init(remote: RemoteAvatarService, local: LocalAvatarPersistence = MockLocalAvatarPersistence()) {
        self.remote = remote
        self.local = local
        self.avatars = nil
    }
    
    // MARK: - Local
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try local.addRecentAvatar(avatar: avatar)
        try await remote.incrementAvatarClickCount(avatarId: avatar.avatarId)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try local.getRecentAvatars()
    }
    
    // MARK: - Remote
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await remote.createAvatart(avatar: avatar, image: image)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await remote.getAvatar(id: id)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await remote.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await remote.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await remote.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForUser(userId: String) async throws -> [AvatarModel] {
        try await remote.getAvatarsForUser(userId: userId)
    }
}
