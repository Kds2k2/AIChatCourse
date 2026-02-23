//
//  EntitlementOption.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 22.02.2026.
//

import SwiftUI

enum EntitlementOption: Codable, CaseIterable {
    case yearly
    
    var productId: String {
        switch self {
        case .yearly:
            var yearly: String = ""
            
            #if MOCK
            yearly = "MOCK"
            #elseif DEV
            yearly = "DimaKryzhanovsky.AIChatCourseDK.Dev.Yearly"
            #else
            yearly = "DimaKryzhanovsky.AIChatCourse.Yearly"
            #endif
            
            return yearly
        }
    }
    
    static var allProductIds: [String] {
        EntitlementOption.allCases.map({ $0.productId })
    }
}
