//
//  UserDefault.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 19.02.2026.
//

import SwiftUI

@propertyWrapper
struct UserDefault<T: Codable> {
    private let key: String
    private let startingValue: T
    
    init(key: String, startingValue: T) {
        self.key = key
        self.startingValue = startingValue
    }
    
    var wrappedValue: T {
        get {
            if let data = UserDefaults.standard.data(forKey: key),
               let value = try? JSONDecoder().decode(T.self, from: data) {
                return value
            }
            
            if let encoded = try? JSONEncoder().encode(startingValue) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
            
            return startingValue
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
    }
}
