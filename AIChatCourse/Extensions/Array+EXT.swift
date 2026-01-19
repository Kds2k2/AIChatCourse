//
//  Array+EXT.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 19.01.2026.
//

import SwiftUI

extension Array {
    
    enum SortOrder {
        case ascending
        case descending
    }
    
    mutating func sortByKeyPath<T: Comparable>(keyPath: KeyPath<Element, T>, order: SortOrder = .ascending) {
        self.sort { item1, item2 in
            let value1 = item1[keyPath: keyPath]
            let value2 = item2[keyPath: keyPath]
            return order == .descending ? value1 > value2 : value1 < value2
        }
    }
    
    func sortedByKeyPath<T: Comparable>(keyPath: KeyPath<Element, T>, order: SortOrder = .ascending) -> [Element] {
        self.sorted { item1, item2 in
            let value1 = item1[keyPath: keyPath]
            let value2 = item2[keyPath: keyPath]
            return order == .descending ? value1 > value2 : value1 < value2
        }
    }
}
