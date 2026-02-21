//
//  CategoryRowTestOption.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 20.02.2026.
//

import SwiftUI

enum CategoryRowTestOption: String, Codable, CaseIterable, Identifiable {
    case original, top, hidden
    
    var id: String { self.rawValue }
    
    static var `default`: Self { .original }
    
    static func random() -> CategoryRowTestOption {
        CategoryRowTestOption.allCases.randomElement() ?? .original
    }
}
