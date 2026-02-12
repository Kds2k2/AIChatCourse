//
//  PushManager.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.02.2026.
//

import SwiftUI
import Foundation

@MainActor
@Observable
class PushManager {
    
    private var logManager: LogManager?
    
    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }
    
    func requestAuthorization() async throws -> Bool {
        let isAuthorized = try await LocalNotifications.requestAuthorization()
        logManager?.addUserProperties(dict: ["push_is_authorized": isAuthorized], isHighPriority: true)
        return isAuthorized
    }
    
    func canRequestAuthorization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }
    
    func schedulePushNotificationForTheNextWeek() {
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()
        
        Task {
            do {
                // Tomorrow
                try await scheduleNotification(
                    title: "Hey you! Ready to chat?",
                    body: "Open AI Chat to begin",
                    triggerDate: Date().addingTimeInterval(days: 1)
                )
                
                // 3
                try await scheduleNotification(
                    title: "Someone sent you a message!",
                    body: "Open AI Chat to respond.",
                    triggerDate: Date().addingTimeInterval(days: 3)
                )
                
                // 5
                try await scheduleNotification(
                    title: "Hey stranger. We miss you!",
                    body: "Don't forget about us.",
                    triggerDate: Date().addingTimeInterval(days: 5)
                )
                
                logManager?.trackEvent(event: Event.weekScheduledSuccess)
            } catch {
                logManager?.trackEvent(event: Event.weekScheduledFail(error: error))
            }
        }
    }
    
    private func scheduleNotification(title: String, body: String, triggerDate: Date) async throws {
        let content = AnyNotificationContent(title: title, body: body)
        let trigger = NotificationTriggerOption.date(date: triggerDate, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case weekScheduledSuccess
        case weekScheduledFail(error: Error)
        
        var eventName: String {
            switch self {
            case .weekScheduledSuccess:      return "PushManager_WeekScheduled_Success"
            case .weekScheduledFail:         return "PushManager_WeekScheduled_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .weekScheduledFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .weekScheduledFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
