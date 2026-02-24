//
//  PaywallTestOption.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 23.02.2026.
//

import SwiftUI

enum PaywallTestOption: String, Codable, CaseIterable, Identifiable {
    case storeKit, revenueCat, custom
    
    var id: String { self.rawValue }
    
    static var `default`: Self { .storeKit }
    
    static func random() -> PaywallTestOption {
        PaywallTestOption.allCases.randomElement() ?? .`default`
    }
}
// _202602_PaywallTest
