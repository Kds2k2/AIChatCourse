//
//  AvatarModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//

import Foundation

struct AvatarModel {
    
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
    
    static var mock: AvatarModel { mocks[0] }
    
    static var mocks: [AvatarModel] {
        [
            AvatarModel(avatarId: UUID().uuidString, name: "Alpha", characterOption: .alien, characterAction: .walking, characterLocation: .space, profileImageName: Constants.randomImage, authorId: UUID().uuidString, createdAt: .now),
            
            AvatarModel(avatarId: UUID().uuidString, name: "Beta", characterOption: .dog, characterAction: .eating, characterLocation: .park, profileImageName: Constants.randomImage, authorId: UUID().uuidString, createdAt: .now),
            
            AvatarModel(avatarId: UUID().uuidString, name: "Gamma", characterOption: .cat, characterAction: .relaxing, characterLocation: .mall, profileImageName: Constants.randomImage, authorId: UUID().uuidString, createdAt: .now),
            
            AvatarModel(avatarId: UUID().uuidString, name: "Delta", characterOption: .man, characterAction: .working, characterLocation: .city, profileImageName: Constants.randomImage, authorId: UUID().uuidString, createdAt: .now)
        ]
    }
}

struct AvatarDescriptionBuilder {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    
    init(characterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init(avatar: AvatarModel) {
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ?? .default
        self.characterLocation = avatar.characterLocation ?? .default
    }
    
    var characterDescription: String {
        "A \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)."
    }
}

enum CharacterOption: String {
    case man, woman, dog, cat, alien
    
    static var `default`: Self { .man }
}

enum CharacterAction: String {
    case smiling, sitting, eating, drinking, walking, shopping, working, relaxing, fighting, crying
    
    static var `default`: Self { .smiling }
}

enum CharacterLocation: String {
    case park, mall, museum, city, desert, forest, space
    
    static var `default`: Self { .park }
}
