//
//  AvatarManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 14.01.2026.
//

import SwiftUI
import Foundation

protocol AvatarService: Sendable {
    func createAvatart(avatar: AvatarModel, image: UIImage) async throws
}

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: AvatarService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    func createAvatart(avatar: AvatarModel, image: UIImage) async throws {
        // Image
        let path = "avatars/\(avatar.avatarId)"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
        
        // Avatar
        var avatar = avatar
        avatar.updateProfileImage(imageName: url.absoluteString)
        try await collection.setDocument(document: avatar)
    }
}

struct MockAvatarService: AvatarService {
    func createAvatart(avatar: AvatarModel, image: UIImage) async throws {
    }
}

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
}
