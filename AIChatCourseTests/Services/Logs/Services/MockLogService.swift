//
//  MockLogService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 24.02.2026.
//

import SwiftUI
@testable import AIChatCourse

@MainActor
final class MockLogService: LogService {
    
    // MARK: - Stored Calls
    
    struct IdentifyCall {
        let userId: String
        let name: String?
        let email: String?
    }
    
    struct UserPropertiesCall {
        let dict: [String: Any]
        let isHighPriority: Bool
    }
    
    struct EventCall {
        let name: String
        let type: LogType
        let parameters: [String: Any]?
    }
    
    // MARK: - Captured Data
    
    private(set) var identifyCalls: [IdentifyCall] = []
    private(set) var userPropertiesCalls: [UserPropertiesCall] = []
    private(set) var deleteUserProfileCallCount = 0
    private(set) var trackedEvents: [EventCall] = []
    private(set) var trackedScreenEvents: [EventCall] = []
    
    // MARK: - LogService
    
    func identifyUser(userId: String, name: String?, email: String?) {
        identifyCalls.append(
            IdentifyCall(userId: userId, name: name, email: email)
        )
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        userPropertiesCalls.append(
            UserPropertiesCall(dict: dict, isHighPriority: isHighPriority)
        )
    }
    
    func deleteUserProfile() {
        deleteUserProfileCallCount += 1
    }
    
    func trackEvent(event: LoggableEvent) {
        trackedEvents.append(
            EventCall(
                name: event.eventName,
                type: event.type,
                parameters: event.parameters
            )
        )
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        trackedScreenEvents.append(
            EventCall(
                name: event.eventName,
                type: event.type,
                parameters: event.parameters
            )
        )
    }
    
    // MARK: - Helpers
    
    func reset() {
        identifyCalls.removeAll()
        userPropertiesCalls.removeAll()
        trackedEvents.removeAll()
        trackedScreenEvents.removeAll()
        deleteUserProfileCallCount = 0
    }
}
