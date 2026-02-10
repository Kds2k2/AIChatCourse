//
//  AvatarModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//

import SwiftUI
import Foundation
import IdentifiableByString

struct AvatarModel: Hashable, Codable, StringIdentifiable {
    
    var id: String { avatarId }
    
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    private(set) var profileImageName: String?
    let authorId: String?
    let createdAt: Date?
    let clickCount: Int?
    
    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        createdAt: Date? = nil,
        clickCount: Int? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.createdAt = createdAt
        self.clickCount = clickCount
    }
    
    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }
    
    enum CodingKeys: String, CodingKey {
        case avatarId = "avatar_id"
        case name
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
        case profileImageName = "profile_image_name"
        case authorId = "author_id"
        case createdAt = "created_at"
        case clickCount = "click_count"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "avatar_\(CodingKeys.avatarId.rawValue)": avatarId,
            "avatar_\(CodingKeys.name.rawValue)": name,
            "avatar_\(CodingKeys.characterOption.rawValue)": characterOption?.rawValue,
            "avatar_\(CodingKeys.characterAction.rawValue)": characterAction?.rawValue,
            "avatar_\(CodingKeys.characterLocation.rawValue)": characterLocation?.rawValue,
            "avatar_\(CodingKeys.profileImageName.rawValue)": profileImageName,
            "avatar_\(CodingKeys.authorId.rawValue)": authorId,
            "avatar_\(CodingKeys.createdAt.rawValue)": createdAt,
            "avatar_\(CodingKeys.clickCount.rawValue)": clickCount
        ]
        
        return dict.compactMapValues({ $0 })
    }
    
    mutating func updateProfileImage(imageName: String) {
        profileImageName = imageName
    }
    
    static func newAvatar(name: String, option: CharacterOption, action: CharacterAction, location: CharacterLocation, authorId: String) -> Self {
        AvatarModel(
            avatarId: UUID().uuidString,
            name: name,
            characterOption: option,
            characterAction: action,
            characterLocation: location,
            profileImageName: nil,
            authorId: authorId,
            createdAt: .now,
            clickCount: 0
        )
    }
    
    static var mock: Self { mocks[0] }
    
    static var mocks: [Self] {
        [
            AvatarModel(
                avatarId: "avatar1",
                name: "Alpha",
                characterOption: .alien,
                characterAction: .walking,
                characterLocation: .space,
                profileImageName: Constants.randomImage,
                authorId: "user1",
                createdAt: .now,
                clickCount: 10
            ),
            
            AvatarModel(
                avatarId: "avatar2",
                name: "Beta",
                characterOption: .dog,
                characterAction: .eating,
                characterLocation: .park,
                profileImageName: Constants.randomImage,
                authorId: "user2",
                createdAt: .now,
                clickCount: 5
            ),
            
            AvatarModel(
                avatarId: "avatar3",
                name: "Gamma",
                characterOption: .cat,
                characterAction: .relaxing,
                characterLocation: .mall,
                profileImageName: Constants.randomImage,
                authorId: "user2",
                createdAt: .now,
                clickCount: 100
            ),
            
            AvatarModel(
                avatarId: "avatar4",
                name: "Delta",
                characterOption: .man,
                characterAction: .working,
                characterLocation: .city,
                profileImageName: Constants.randomImage,
                authorId: "user3",
                createdAt: .now,
                clickCount: 20
            )
        ]
    }
}
