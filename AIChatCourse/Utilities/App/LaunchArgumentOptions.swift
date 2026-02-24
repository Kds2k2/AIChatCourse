//
//  LaunchArgumentOptions.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 24.02.2026.
//

import SwiftUI
import Foundation

public enum LaunchArgumentOptions: String {
    case signIn                 = "SIGN_IN"
    case signOut                = "SIGN_OUT"
    case onboardingCommunity    = "ONBCOMM"
    case screenCreateAvatar     = "SCREEN_CREATEAVATAR"
    
    var value: Bool {
        ProcessInfo.processInfo.arguments.contains(self.rawValue)
    }
}
