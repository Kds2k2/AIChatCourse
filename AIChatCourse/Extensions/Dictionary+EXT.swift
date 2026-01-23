//
//  Dictionary+EXT.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 23.01.2026.
//

import SwiftUI

extension Dictionary where Key == String, Value == Any {
    var asAlphabeticalArray: [(key: String, value: Any)] {
        self
            .map {(key: $0, value: $1)}
            .sortedByKeyPath(keyPath: \.key)
    }
}
