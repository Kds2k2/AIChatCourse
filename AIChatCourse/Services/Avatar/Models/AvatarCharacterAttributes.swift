//
//  AvatarCharacterAttributes.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 05.01.2026.
//

import Foundation

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
        let prefix = characterOption.isStartsWithVowel ? "An" : "A"
        return "\(prefix) \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)."
    }
}

enum CharacterOption: String, CaseIterable, Hashable {
    case man, woman, dog, cat, alien
    
    static var `default`: Self { .man }
    
    var isStartsWithVowel: Bool {
        self.rawValue
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .contains { "aeiou".contains($0) }
    }
}

enum CharacterAction: String, CaseIterable, Hashable {
    case smiling, sitting, eating, drinking, walking, shopping, working, relaxing, fighting, crying
    
    static var `default`: Self { .smiling }
}

enum CharacterLocation: String, CaseIterable, Hashable {
    case park, mall, museum, city, desert, forest, space
    
    static var `default`: Self { .park }
}
