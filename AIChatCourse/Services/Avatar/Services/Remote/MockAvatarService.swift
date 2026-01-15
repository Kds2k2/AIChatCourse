//
//  MockAvatarService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 14.01.2026.
//

import SwiftUI

struct MockAvatarService: RemoteAvatarService {
    let avatars: [AvatarModel]
    let delay: Double
    let showError: Bool
    
    init(avatars: [AvatarModel] = AvatarModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.avatars = avatars
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func getAvatarsForUser(userId: String) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        guard let avatar = avatars.first(where: { $0.id == id }) else {
            throw URLError(.noPermissionsToReadFile)
        }
        
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatar
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func createAvatart(avatar: AvatarModel, image: UIImage) async throws {
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        
    }
    
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws {
        
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
    }
}
