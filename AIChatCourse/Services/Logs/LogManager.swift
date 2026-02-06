//
//  LogManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 05.02.2026.
//

import SwiftUI

@MainActor
@Observable
class LogManager {
    
    private let services: [LogService]
    
    init(services: [LogService] = []) {
        self.services = services
    }
    
    func identifyUser(userId: String, name: String?, email: String?) {
        services.forEach {
            $0.identifyUser(userId: userId, name: name, email: email)
        }
    }
    
    func addUserProperties(dict: [String: Any]) {
        services.forEach {
            $0.addUserProperties(dict: dict)
        }
    }
    
    func deleteUserProfile() {
        services.forEach {
            $0.deleteUserProfile()
        }
    }
    
    func trackEvent(event: LoggableEvent) {
        services.forEach {
            $0.trackEvent(event: event)
        }
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        services.forEach {
            $0.trackScreenEvent(event: event)
        }
    }
}
