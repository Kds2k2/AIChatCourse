//
//  AvatarModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//

import Foundation

struct AvatarModel: Hashable {
    
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
    let authorId: String?
    let createdAt: Date?
    
    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        createdAt: Date? = nil,
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.createdAt = createdAt
    }
    
    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }
    
    static var mock: Self { mocks[0] }
    
    static var mocks: [Self] {
        [
            AvatarModel(avatarId: UUID().uuidString, name: "Alpha", characterOption: .alien, characterAction: .walking, characterLocation: .space, profileImageName: Constants.randomImage, authorId: UUID().uuidString, createdAt: .now),
            
            AvatarModel(avatarId: UUID().uuidString, name: "Beta", characterOption: .dog, characterAction: .eating, characterLocation: .park, profileImageName: Constants.randomImage, authorId: UUID().uuidString, createdAt: .now),
            
            AvatarModel(avatarId: UUID().uuidString, name: "Gamma", characterOption: .cat, characterAction: .relaxing, characterLocation: .mall, profileImageName: Constants.randomImage, authorId: UUID().uuidString, createdAt: .now),
            
            AvatarModel(avatarId: UUID().uuidString, name: "Delta", characterOption: .man, characterAction: .working, characterLocation: .city, profileImageName: Constants.randomImage, authorId: UUID().uuidString, createdAt: .now)
        ]
    }
}
