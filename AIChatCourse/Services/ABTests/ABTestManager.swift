//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 18.02.2026.
//

import SwiftUI

@MainActor
@Observable
class ABTestManager {
    
    private let service: ABTestService
    private var logManager: LogManager?
    
    var activeTests: ActiveABTests
    
    init(service: ABTestService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.activeTests = service.activeTests
        self.configure()
    }
    
    private func configure() {
        Task {
            do {
                activeTests = try await service.fetchUpdatedConfig()
                logManager?.trackEvent(event: Event.fetchRemoteConfigSuccess)
                logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: true)
            } catch {
                logManager?.trackEvent(event: Event.fetchRemoteConfigFail(error: error))
            }
        }
    }
    
    func override(updateTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updateTests)
        self.configure()
    }
    
    enum Event: LoggableEvent {
        case fetchRemoteConfigSuccess
        case fetchRemoteConfigFail(error: Error)
        
        var eventName: String {
            switch self {
            case .fetchRemoteConfigSuccess:   "ABMan_FetchRemoteConfig_Success"
            case .fetchRemoteConfigFail:      "ABMan_FetchRemoteConfig_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .fetchRemoteConfigFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .fetchRemoteConfigFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
