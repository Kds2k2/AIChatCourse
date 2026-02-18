//
//  AppKeys.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 13.01.2026.
//

import SwiftUI

struct AppKeys {
    static let mixpanel: String = {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "MIXPANEL_PROJECT_TOKEN"
        ) as? String else {
            fatalError("MIXPANEL_PROJECT_TOKEN not set")
        }
        return key
    }()
}
