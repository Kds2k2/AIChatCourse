//
//  AppKeys.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 13.01.2026.
//

import SwiftUI

struct AppKeys {
    static let openAI: String = {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "OPENAI_API_KEY"
        ) as? String else {
            fatalError("OPENAI_API_KEY not set")
        }
        return key
    }()
}
