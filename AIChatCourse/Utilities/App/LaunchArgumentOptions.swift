//
//  LaunchArgumentOptions.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 24.02.2026.
//

import SwiftUI
import Foundation

public enum LaunchArgumentOptions: String {
    case signIn  =  "SIGN_IN"
    case signOut =  "SIGN_OUT"
    
    var value: Bool {
        ProcessInfo.processInfo.arguments.contains(self.rawValue)
    }
}
