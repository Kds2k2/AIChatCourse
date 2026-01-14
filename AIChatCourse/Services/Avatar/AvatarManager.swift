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
    
    private let service: AvatarService
    private(set) var avatars: AvatarModel?
    
    init(service: AvatarService) {
        self.service = service
        self.avatars = nil
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await service.createAvatart(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await service.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await service.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await service.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForUser(userId: String) async throws -> [AvatarModel] {
        try await service.getAvatarsForUser(userId: userId)
    }
}
