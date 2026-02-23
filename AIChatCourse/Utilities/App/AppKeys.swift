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
    
    static let revenueCat: String = {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "REVENUECAT_API_KEY"
        ) as? String else {
            fatalError("REVENUECAT_API_KEY not set")
        }
        return key
    }()
    
    static let revenueCatDev: String = {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "REVENUECAT_DEV_API_KEY"
        ) as? String else {
            fatalError("REVENUECAT_DEV_API_KEY not set")
        }
        return key
    }()

    static let revenueCatTest: String = {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "REVENUECAT_TEST_API_KEY"
        ) as? String else {
            fatalError("REVENUECAT_TEST_API_KEY not set")
        }
        return key
    }()
}
