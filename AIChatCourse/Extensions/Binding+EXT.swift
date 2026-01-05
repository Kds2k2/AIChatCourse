//
//  Binding+EXT.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 05.01.2026.
//

import SwiftUI

extension Binding where Value == Bool {
    
    init<T: Sendable>(ifNotNil value: Binding<T?>) {
        self.init(get: {
            value.wrappedValue != nil
        }, set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        })
    }
}
