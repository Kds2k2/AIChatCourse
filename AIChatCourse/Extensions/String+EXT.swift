//
//  String+EXT.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.02.2026.
//

import Foundation

extension String {
    func clipped(maxCharactes: Int) -> String {
        String(prefix(maxCharactes))
    }
    
    func replaceSpacesWithUnderscores() -> String {
        self.replacingOccurrences(of: " ", with: "_")
    }
}

extension String {
    static func convertToStirng(_ value: Any) -> String? {
        switch value {
        case let value as String:
            return value
        case let value as Bool:
            return value.description
        case let value as Int:
            return String(value)
        case let value as Double:
            return String(value)
        case let value as Float:
            return String(value)
        case let value as Date:
            return value.formatted(date: .abbreviated, time: .shortened)
        case let array as [Any]:
            return array.compactMap({ String.convertToStirng($0) })
                .sorted()
                .joined(separator: ", ")
        case let value as CustomStringConvertible:
            return value.description
        default:
            return nil
        }
    }
}
