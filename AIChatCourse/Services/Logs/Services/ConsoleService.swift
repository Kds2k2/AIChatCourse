//
//  ConsoleService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 05.02.2026.
//

import SwiftUI
import OSLog

actor LogSystem {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConsoleLogger")
    
    func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }
    
    nonisolated func log(level: LogType, message: String) {
        Task {
            await log(level: level.OSLogType, message: message)
        }
    }
}

enum LogType {
    case info
    case analytic
    case waring
    case severe
    
    var emoji: String {
        switch self {
        case .info:
            "👋"
        case .analytic:
            "📈"
        case .waring:
            "⚠️"
        case .severe:
            "🚨"
        }
    }
    
    var OSLogType: OSLogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .default
        case .waring:
            return .error
        case .severe:
            return .fault
        }
    }
}

struct ConsoleService: LogService {
    
    let logger = LogSystem()
    private let printParameters: Bool
    
    init(printParameters: Bool = true) {
        self.printParameters = printParameters
    }
    
    func identifyUser(userId: String, name: String?, email: String?) {
        let level = LogType.analytic
        let string = """
        \(level.emoji) Identify User:
            userId: \(userId),
            name: \(name ?? "unknown"),
            email: \(email ?? "unknown")
        """
        
        logger.log(level: level, message: string)
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        
        let level = LogType.analytic
        var string = """
        \(level.emoji) User properties:
        """
        
        if printParameters {
            let sorted = dict.keys.sorted()
            for key in sorted {
                if let value = dict[key] {
                    string += "\n(key: \(key), value: \(value)"
                }
            }
        }
        
        logger.log(level: level, message: string)
    }
    
    func deleteUserProfile() {
        let level = LogType.analytic
        let string = """
        \(level.emoji) Delete User Profile
        """
        
        logger.log(level: level, message: string)
    }
    
    func trackEvent(event: any LoggableEvent) {
        var string = """
        \(event.type.emoji) \(event.eventName):
        """
        
        if printParameters {
            if let parameters = event.parameters, !parameters.isEmpty {
                let sorted = parameters.keys.sorted()
                for key in sorted {
                    if let value = parameters[key] {
                        string += "\n(key: \(key), value: \(value)"
                    }
                }
            }
        }
        
        logger.log(level: event.type, message: string)
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
