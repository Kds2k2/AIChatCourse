//
//  Collection+EXT.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 14.01.2026.
//

import SwiftUI

extension Collection {
    func first(upTo value: Int) -> [Element]? {
        guard !isEmpty else { return nil }
        
        let maxItems = Swift.min(count, value)
        return Array(prefix(maxItems))
    }
    
    func last(upTo value: Int) -> [Element]? {
        guard !isEmpty else { return nil }
        
        let maxItems = Swift.min(count, value)
        return Array(suffix(maxItems))
    }
}
