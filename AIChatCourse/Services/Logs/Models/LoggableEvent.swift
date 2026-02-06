//
//  LoggableEvent.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.02.2026.
//

import SwiftUI

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}

struct AnyLoggableEvent: LoggableEvent {
    let eventName: String
    let parameters: [String: Any]?
    let type: LogType
    
    init(eventName: String, parameters: [String: Any]? = nil, type: LogType) {
        self.eventName = eventName
        self.parameters = parameters
        self.type = type
    }
}
