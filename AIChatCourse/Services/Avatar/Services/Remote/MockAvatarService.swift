//
//  MockAvatarService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 14.01.2026.
//

import SwiftUI

struct MockAvatarService: RemoteAvatarService {
    func getAvatarsForUser(userId: String) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.shuffled()
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await Task.sleep(for: .seconds(1))
        return AvatarModel.mock
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(1))
        return AvatarModel.mocks.shuffled()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(3))
        return AvatarModel.mocks.shuffled()
    }
    
    func createAvatart(avatar: AvatarModel, image: UIImage) async throws {
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.filter({ $0.characterOption == category })
    }
}
